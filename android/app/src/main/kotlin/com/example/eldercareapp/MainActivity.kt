package com.example.eldercareapp

import android.content.Context
import android.media.AudioManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val CHANNEL = "eldercareapp/audio"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
			when (call.method) {
				"setSpeakerphoneOn" -> {
					val on = call.argument<Boolean>("on") ?: false
					val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
					try {
						if (on) {
							audioManager.mode = AudioManager.MODE_IN_COMMUNICATION
							audioManager.isSpeakerphoneOn = true
						} else {
							audioManager.isSpeakerphoneOn = false
							audioManager.mode = AudioManager.MODE_NORMAL
						}
						result.success(true)
					} catch (e: Exception) {
						result.error("AUDIO_ERROR", e.message, null)
					}
				}
				else -> result.notImplemented()
			}
		}
	}
}
