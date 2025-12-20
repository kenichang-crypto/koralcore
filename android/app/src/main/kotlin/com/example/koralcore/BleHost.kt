package com.example.koralcore

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.content.ContextCompat
import java.util.Locale
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap

/**
 * Platform-side BLE host. Connections are registered separately; this class is in charge of
 * marshalling write requests originating from Flutter.
 */
class BleHost(private val context: Context) : BleConnectionManager.Listener {
  private val tag = "BleHost"
  private val bluetoothManager: BluetoothManager? =
    context.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
  private val connectionRegistry = ConnectionRegistry()
  private val connectionManager = BleConnectionManager(
    context = context,
    bluetoothManager = bluetoothManager,
    permissionChecker = ::hasConnectPermission,
    listener = this,
  )
  private var notificationSink: NotificationSink? = null

  fun sendCommand(deviceId: String?, payload: ByteArray, mode: String): BleCommandResult {
    Log.d(
      tag,
      "sendCommand(deviceId=" + deviceId + ", mode=" + mode + ", bytes=" + payload.size + ")",
    )

    if (deviceId.isNullOrBlank()) {
      return BleCommandResult.Failure("deviceId is required")
    }

    val targetDeviceId = deviceId.trim()

    val adapter = bluetoothManager?.adapter
      ?: return BleCommandResult.Failure("Bluetooth adapter unavailable")
    if (!adapter.isEnabled) {
      return BleCommandResult.Failure("Bluetooth adapter disabled")
    }
    if (!hasConnectPermission()) {
      return BleCommandResult.Failure("Missing BLUETOOTH_CONNECT permission")
    }

    val gatt = connectionRegistry.get(targetDeviceId)
      ?: return BleCommandResult.NotConnected("No active GATT for $targetDeviceId")
    val characteristic = resolveWriteCharacteristic(gatt)
      ?: return BleCommandResult.Failure("Writable characteristic not found")

    configureWriteType(characteristic, mode)
    characteristic.value = payload

    val started = dispatchWrite(gatt, characteristic)
    return if (started) {
      BleCommandResult.Success()
    } else {
      BleCommandResult.Failure("writeCharacteristic returned false")
    }
  }

  fun connect(deviceId: String): Boolean {
    return connectionManager.connect(deviceId)
  }

  fun disconnect(deviceId: String) {
    connectionManager.disconnect(deviceId)
  }

  fun setNotificationSink(sink: NotificationSink?) {
    notificationSink = sink
  }

  override fun onConnected(deviceId: String, gatt: BluetoothGatt) {
    registerConnection(deviceId, gatt)
  }

  override fun onDisconnected(deviceId: String) {
    unregisterConnection(deviceId)
  }

  override fun onNotification(
    deviceId: String,
    characteristic: BluetoothGattCharacteristic,
    value: ByteArray,
  ) {
    Log.d(tag, "Notification(" + characteristic.uuid + ") len=" + value.size + " device=" + deviceId)
    notificationSink?.onNotify(deviceId, characteristic.uuid, value)
  }

  fun registerConnection(deviceId: String, gatt: BluetoothGatt) {
    connectionRegistry.put(deviceId, gatt)
  }

  fun unregisterConnection(deviceId: String) {
    connectionRegistry.remove(deviceId)
  }

  private fun hasConnectPermission(): Boolean {
    return if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
      true
    } else {
      ContextCompat.checkSelfPermission(context, Manifest.permission.BLUETOOTH_CONNECT) ==
          PackageManager.PERMISSION_GRANTED
    }
  }

  private fun configureWriteType(characteristic: BluetoothGattCharacteristic, mode: String) {
    characteristic.writeType =
        if (mode == "withoutResponse") {
          BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE
        } else {
          BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
        }
  }

  private fun resolveWriteCharacteristic(gatt: BluetoothGatt): BluetoothGattCharacteristic? {
    val services = gatt.services ?: return null
    for (service in services) {
      for (characteristic in service.characteristics) {
        if (characteristic.canWrite()) {
          return characteristic
        }
      }
    }
    return null
  }

  private fun BluetoothGattCharacteristic.canWrite(): Boolean {
    val props = properties
    return (props and BluetoothGattCharacteristic.PROPERTY_WRITE) != 0 ||
        (props and BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE) != 0
  }

  @SuppressLint("MissingPermission")
  private fun dispatchWrite(
    gatt: BluetoothGatt,
    characteristic: BluetoothGattCharacteristic,
  ): Boolean {
    return gatt.writeCharacteristic(characteristic)
  }

  private class ConnectionRegistry {
    private val connections = ConcurrentHashMap<String, BluetoothGatt>()

    fun get(deviceId: String): BluetoothGatt? {
      return connections[normalize(deviceId)]
    }

    fun put(deviceId: String, gatt: BluetoothGatt) {
      connections[normalize(deviceId)] = gatt
    }

    fun remove(deviceId: String) {
      connections.remove(normalize(deviceId))
    }

    private fun normalize(deviceId: String): String {
      return deviceId.trim().lowercase(Locale.US)
    }
  }
  fun interface NotificationSink {
    fun onNotify(deviceId: String, characteristicUuid: UUID, payload: ByteArray)
  }
}

sealed class BleCommandResult {
  data class Success(val payload: ByteArray? = null) : BleCommandResult()
  data class NotConnected(val reason: String) : BleCommandResult()
  data class NotReady(val reason: String) : BleCommandResult()
  data class Failure(val reason: String) : BleCommandResult()
}
