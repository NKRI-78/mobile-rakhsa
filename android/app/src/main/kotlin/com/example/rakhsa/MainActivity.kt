package com.inovatiftujuh8.rakhsa

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.inovatiftujuh8.rakhsa/location"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Safely access the binaryMessenger using a null check
        flutterEngine?.let { engine ->
            // Initialize the MethodChannel
            val methodChannel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)

            // Ensure that the FlutterEngine is kept alive
            engine.lifecycleChannel.appIsResumed()

            // Assign methodChannel to MethodChannelHelper
            MethodChannelHelper.methodChannel = methodChannel

            methodChannel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "startService" -> {
                        startLocationService()
                        result.success("Location service started")
                    }
                    "stopService" -> {
                        stopLocationService()
                        result.success("Location service stopped")
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        // Make sure the FlutterEngine is attached to the activity lifecycle
        flutterEngine?.let { engine ->
            if (!engine.dartExecutor.isExecutingDart) {
                engine.dartExecutor.executeDartEntrypoint(
                    DartExecutor.DartEntrypoint.createDefault()
                )
            }
        }
    }

    private fun startLocationService() {
        val intent = Intent(this, LocationService::class.java)
        startForegroundService(intent)
    }

    private fun stopLocationService() {
        val intent = Intent(this, LocationService::class.java)
        stopService(intent)
    }
}
