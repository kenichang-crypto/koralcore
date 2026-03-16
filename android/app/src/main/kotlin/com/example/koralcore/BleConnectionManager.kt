package com.example.koralcore

import android.annotation.SuppressLint
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCallback
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattDescriptor
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import java.util.Locale
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap

private const val TAG = "BleConnectionMgr"
private val CLIENT_CHARACTERISTIC_CONFIG_UUID: UUID =
  UUID.fromString("00002902-0000-1000-8000-00805f9b34fb")

/**
 * Minimal GATT connection manager responsible for establishing connections and propagating
 * characteristic notifications to the BLE host.
 */
class BleConnectionManager(
  private val context: Context,
  private val bluetoothManager: BluetoothManager?,
  private val permissionChecker: () -> Boolean,
  private val listener: Listener,
) {
  companion object {
    private const val MAX_RETRY_ATTEMPTS = 3
    private const val RETRY_DELAY_MS = 200L
  }

  private val handler = Handler(Looper.getMainLooper())
  private val connections = ConcurrentHashMap<String, BluetoothGatt>()
  private val retryCounts = ConcurrentHashMap<String, Int>()

  interface Listener {
    fun onConnected(deviceId: String, gatt: BluetoothGatt)
    fun onDisconnected(deviceId: String)
    fun onNotification(
      deviceId: String,
      characteristic: BluetoothGattCharacteristic,
      value: ByteArray,
    )
  }

  @SuppressLint("MissingPermission")
  fun connect(deviceId: String): Boolean {
    if (deviceId.isBlank()) {
      Log.w(TAG, "connect: missing deviceId")
      return false
    }
    if (!permissionChecker()) {
      Log.w(TAG, "connect: missing BLUETOOTH_CONNECT permission")
      return false
    }
    val adapter = bluetoothManager?.adapter
    if (adapter == null || !adapter.isEnabled) {
      Log.w(TAG, "connect: bluetooth adapter unavailable or disabled")
      return false
    }

    val device = try {
      adapter.getRemoteDevice(deviceId)
    } catch (error: IllegalArgumentException) {
      Log.w(TAG, "connect: invalid deviceId=$deviceId", error)
      return false
    }

    val callback = object : BluetoothGattCallback() {
      override fun onConnectionStateChange(
        gatt: BluetoothGatt,
        status: Int,
        newState: Int,
      ) {
        if (status != BluetoothGatt.GATT_SUCCESS) {
          Log.w(TAG, "onConnectionStateChange: status=$status device=$deviceId")
          if (status == 133) {
            val attempts = (retryCounts[normalize(deviceId)] ?: 0) + 1
            if (attempts < MAX_RETRY_ATTEMPTS) {
              Log.d(TAG, "GATT 133 retry $attempts/$MAX_RETRY_ATTEMPTS for $deviceId")
              retryCounts[normalize(deviceId)] = attempts
              closeConnection(deviceId)
              listener.onDisconnected(deviceId)
              handler.postDelayed({
                connect(deviceId)
              }, RETRY_DELAY_MS)
              return
            }
          }
          retryCounts.remove(normalize(deviceId))
          closeConnection(deviceId)
          listener.onDisconnected(deviceId)
          return
        }
        retryCounts.remove(normalize(deviceId))
        if (newState == BluetoothProfile.STATE_CONNECTED) {
          Log.d(TAG, "GATT connected: $deviceId")
          listener.onConnected(deviceId, gatt)
          gatt.discoverServices()
        } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
          Log.d(TAG, "GATT disconnected: $deviceId")
          closeConnection(deviceId)
          listener.onDisconnected(deviceId)
        }
      }

      override fun onServicesDiscovered(gatt: BluetoothGatt, status: Int) {
        if (status != BluetoothGatt.GATT_SUCCESS) {
          Log.w(TAG, "Service discovery failed for $deviceId status=$status")
          return
        }
        enableNotifications(deviceId, gatt)
      }

      override fun onCharacteristicChanged(
        gatt: BluetoothGatt,
        characteristic: BluetoothGattCharacteristic,
        value: ByteArray,
      ) {
        handleCharacteristicChanged(deviceId, characteristic, value)
      }

      @Suppress("DEPRECATION")
      override fun onCharacteristicChanged(
        gatt: BluetoothGatt,
        characteristic: BluetoothGattCharacteristic,
      ) {
        val value = characteristic.value ?: ByteArray(0)
        handleCharacteristicChanged(deviceId, characteristic, value)
      }

      private fun handleCharacteristicChanged(
        deviceId: String,
        characteristic: BluetoothGattCharacteristic,
        value: ByteArray,
      ) {
        listener.onNotification(deviceId, characteristic, value.clone())
      }
    }

    Log.d(TAG, "Connecting to $deviceId ...")
    val gatt = device.connectGatt(context, false, callback, BluetoothDevice.TRANSPORT_LE)
    if (gatt != null) {
      connections[normalize(deviceId)] = gatt
      return true
    }
    Log.w(TAG, "connect: connectGatt returned null for $deviceId")
    return false
  }

  @SuppressLint("MissingPermission")
  fun disconnect(deviceId: String) {
    val normalized = normalize(deviceId)
    val gatt = connections.remove(normalized) ?: return
    try {
      gatt.disconnect()
    } finally {
      gatt.close()
    }
  }

  @SuppressLint("MissingPermission")
  private fun enableNotifications(deviceId: String, gatt: BluetoothGatt) {
    val services = gatt.services ?: return
    var enabledCharacteristic = false
    for (service in services) {
      for (characteristic in service.characteristics) {
        if (characteristic.canNotify()) {
          if (!permissionChecker()) {
            Log.w(TAG, "enableNotifications: missing permission for $deviceId")
            return
          }
          val set = gatt.setCharacteristicNotification(characteristic, true)
          Log.d(TAG, "Enable notify ($set) for ${characteristic.uuid} on $deviceId")
          enabledCharacteristic = true
          val descriptor = characteristic.getDescriptor(CLIENT_CHARACTERISTIC_CONFIG_UUID)
          if (descriptor != null) {
            descriptor.value =
              BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE
            gatt.writeDescriptor(descriptor)
          }
          // Continue to enable notifications for other characteristics/services
        }
      }
    }
    if (!enabledCharacteristic) {
      Log.w(TAG, "No notifiable characteristic found for $deviceId")
    }
  }

  private fun closeConnection(deviceId: String) {
    val normalized = normalize(deviceId)
    val gatt = connections.remove(normalized) ?: return
    gatt.close()
  }

  private fun BluetoothGattCharacteristic.canNotify(): Boolean {
    val props = properties
    return (props and BluetoothGattCharacteristic.PROPERTY_NOTIFY) != 0 ||
        (props and BluetoothGattCharacteristic.PROPERTY_INDICATE) != 0
  }

  private fun normalize(deviceId: String): String {
    return deviceId.trim().lowercase(Locale.US)
  }
}
