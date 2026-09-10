package com.luster.booth360.camera

import android.content.Context
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Native Android Camera2 bridge providing hardware capabilities query,
 * high-FPS detection, and exposure locking.
 */
class Camera2Bridge(private val context: Context) : MethodCallHandler {
    companion object {
        const val CHANNEL = "com.luster.booth360/camera2"
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getAdvancedCapabilities" -> {
                try {
                    val manager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
                    val cameraIdList = manager.cameraIdList
                    val capabilities = mutableMapOf<String, Any>()

                    for (id in cameraIdList) {
                        val chars = manager.getCameraCharacteristics(id)
                        val facing = chars.get(CameraCharacteristics.LENS_FACING)
                        if (facing == CameraCharacteristics.LENS_FACING_BACK) {
                            val fpsRanges = chars.get(CameraCharacteristics.CONTROL_AE_AVAILABLE_TARGET_FPS_RANGES)
                            val maxFps = fpsRanges?.maxOfOrNull { it.upper } ?: 30
                            val hasFlash = chars.get(CameraCharacteristics.FLASH_INFO_AVAILABLE) ?: false

                            capabilities["maxFps"] = maxFps
                            capabilities["hasFlash"] = hasFlash
                            capabilities["cameraId"] = id
                            break
                        }
                    }
                    result.success(capabilities)
                } catch (e: Exception) {
                    result.error("CAMERA_CAPABILITY_ERROR", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }
}
