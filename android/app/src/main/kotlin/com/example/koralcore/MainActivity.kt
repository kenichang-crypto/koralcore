package com.example.koralcore

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val channelName = "koralcore/ble_transport"
	private var methodChannel: MethodChannel? = null
	private lateinit var bleHost: BleHost
	private val mainHandler = Handler(Looper.getMainLooper())

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		bleHost = BleHost(applicationContext)
		val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
		channel.setMethodCallHandler { call, result ->
			when (call.method) {
				"write" -> handleWrite(call, result)
				"connect" -> handleConnect(call, result)
				else -> result.notImplemented()
			}
		}
		methodChannel = channel
		bleHost.setNotificationSink { deviceId, characteristicUuid, payload ->
			mainHandler.post {
				methodChannel?.invokeMethod(
					"notify",
					mapOf(
						"deviceId" to deviceId,
						"characteristic" to characteristicUuid.toString(),
						"payload" to payload,
					),
				)
			}
		}
	}

	override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
		bleHost.setNotificationSink(null)
		methodChannel?.setMethodCallHandler(null)
		methodChannel = null
		super.cleanUpFlutterEngine(flutterEngine)
	}

	private fun handleWrite(call: MethodCall, result: MethodChannel.Result) {
		val deviceId = call.argument<String>("deviceId")
		val payload = call.argument<ByteArray>("payload")
		val mode = call.argument<String>("mode") ?: "withResponse"
		if (payload == null) {
			result.error("INVALID_ARGUMENT", "payload is required", null)
			return
		}

		when (val hostResult = bleHost.sendCommand(deviceId, payload, mode)) {
			is BleCommandResult.Success -> result.success(successMap(hostResult.payload))
			is BleCommandResult.NotConnected ->
				result.success(failureMap("notConnected", hostResult.reason))
			is BleCommandResult.NotReady ->
				result.success(failureMap("notReady", hostResult.reason))
			is BleCommandResult.Failure ->
				result.success(failureMap("bleWriteFailed", hostResult.reason))
		}
	}

	private fun handleConnect(call: MethodCall, result: MethodChannel.Result) {
		val deviceId = call.argument<String>("deviceId")
		if (deviceId.isNullOrBlank()) {
			result.error("INVALID_ARGUMENT", "deviceId is required", null)
			return
		}
		val connected = bleHost.connect(deviceId.trim())
		result.success(connected)
	}

	private fun successMap(payload: ByteArray?): Map<String, Any?> {
		val response = mutableMapOf<String, Any?>("status" to "ack")
		if (payload != null) {
			response["payload"] = payload
		}
		return response
	}

	private fun failureMap(errorCode: String, reason: String): Map<String, Any?> {
		return mutableMapOf(
			"status" to "failure",
			"errorCode" to errorCode,
			"message" to reason,
		)
	}
}
