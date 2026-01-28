// package com.example.ckservice

// import io.flutter.embedding.android.FlutterFragmentActivity

// class MainActivity: FlutterFragmentActivity()
// package com.example.ckservice

// import android.app.NotificationChannel
// import android.app.NotificationManager
// import android.media.AudioAttributes
// import android.net.Uri
// import android.os.Build
// import android.os.Bundle
// import io.flutter.embedding.android.FlutterActivity

// class MainActivity: FlutterActivity() {
//     override fun onCreate(savedInstanceState: Bundle?) {
//         super.onCreate(savedInstanceState)
//         createNotificationChannel()
//     }
//     private fun createNotificationChannel() {
//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//             val soundUri = Uri.parse("android.resource://" + packageName + "/" + R.raw.ringtone)
//             val attributes = AudioAttributes.Builder()
//                 .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
//                 .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
//                 .build()

//             val channel = NotificationChannel(
//                 "call_channel",
//                 "Incoming Call",
//                 NotificationManager.IMPORTANCE_HIGH
//             ).apply {
//                 setSound(soundUri, attributes)
//                 enableVibration(true)
//                 vibrationPattern = longArrayOf(500, 1000, 1000)
//             }

//             val manager = getSystemService(NotificationManager::class.java)
//             manager.createNotificationChannel(channel)
//         }
//     }
// }
// package com.example.ckservice

// import android.app.NotificationChannel
// import android.app.NotificationManager
// import android.media.AudioAttributes
// import android.net.Uri
// import android.os.Build
// import android.os.Bundle
// import io.flutter.embedding.android.FlutterActivity

// class MainActivity: FlutterActivity() {
//     override fun onCreate(savedInstanceState: Bundle?) {
//         super.onCreate(savedInstanceState)
//         createNotificationChannel()
//     }

//     private fun createNotificationChannel() {
//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//             val soundUri = Uri.parse("android.resource://" + packageName + "/" + R.raw.ringtone)
//             val attributes = AudioAttributes.Builder()
//                 .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
//                 .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
//                 .build()

//             val channel = NotificationChannel(
//                 "call_channel",
//                 "Incoming Call",
//                 NotificationManager.IMPORTANCE_HIGH
//             ).apply {
//                 setSound(soundUri, attributes)
//                 enableVibration(true)
//                 vibrationPattern = longArrayOf(500, 1000, 1000)
//             }

//             val manager = getSystemService(NotificationManager::class.java)
//             manager.createNotificationChannel(channel)
//         }
//     }
// }
package com.example.ckservice

import android.app.NotificationChannel
import android.app.NotificationManager
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.ckservice/ringtone"
    private var mediaPlayer: android.media.MediaPlayer? = null

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        io.flutter.plugin.common.MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startRingtone" -> {
                    startRingtone()
                    result.success(null)
                }
                "stopRingtone" -> {
                    stopRingtone()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startRingtone() {
        try {
            if (mediaPlayer != null) return

            val notification = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
            mediaPlayer = android.media.MediaPlayer.create(applicationContext, notification)
            mediaPlayer?.isLooping = true
            mediaPlayer?.start()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun stopRingtone() {
        try {
            mediaPlayer?.stop()
            mediaPlayer?.release()
            mediaPlayer = null
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val soundUri = Uri.parse("android.resource://" + packageName + "/" + R.raw.ringtone)
            val attributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()

            val channel = NotificationChannel(
                "call_channel",
                "Incoming Call",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                setSound(soundUri, attributes)
                enableVibration(true)
                vibrationPattern = longArrayOf(500, 1000, 1000)
            }

            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }
}
