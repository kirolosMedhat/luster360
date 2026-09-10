package com.luster.booth360

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.luster.booth360.camera.Camera2Bridge

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register native Camera2 bridge
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, Camera2Bridge.CHANNEL)
            .setMethodCallHandler(Camera2Bridge(applicationContext))
    }
}
