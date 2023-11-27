package com.example.drimaes_coding_challenge

import androidx.annotation.NonNull

import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "demo").setMethodCallHandler {
                call, result ->
            when (call.method) {
                "getVersionInfo" -> {
                    getVersionInfo(result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getVersionInfo(result: MethodChannel.Result) {
        try {
            val packageInfo: PackageInfo =
                packageManager.getPackageInfo(packageName, 0)
            val versionCode = packageInfo.versionCode
            val versionName = packageInfo.versionName

            result.success(mapOf("versionCode" to versionCode, "versionName" to versionName))
        } catch (e: PackageManager.NameNotFoundException) {
            result.error("VERSION_ERROR", "Error getting version info", null)
        }
    }
}
