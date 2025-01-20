package com.inovatiftujuh8.rakhsa

import io.flutter.plugin.common.MethodChannel

object MethodChannelHelper {
    var methodChannel: MethodChannel? = null

    fun sendLocationData(latitude: Double, longitude: Double) {
        methodChannel?.invokeMethod("updateLocation", mapOf("latitude" to latitude, "longitude" to longitude))
    }
}