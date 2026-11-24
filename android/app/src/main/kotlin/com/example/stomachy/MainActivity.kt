
package com.example.stomachy

import android.content.ActivityNotFoundException
import android.content.Intent
import android.provider.AlarmClock
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.stomachy/alarm"
    private val TAG = "StomachyAlarm"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "setConsultationAlarm" -> {
                    val hour = call.argument<Int>("hour")
                    val minute = call.argument<Int>("minute")
                    val message = call.argument<String>("message")
                        ?: "Waktunya konsultasi STOMACHY"

                    if (
                        hour == null ||
                        minute == null ||
                        hour !in 0..23 ||
                        minute !in 0..59
                    ) {
                        result.error(
                            "INVALID_TIME",
                            "Jam atau menit alarm tidak valid.",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        Log.d(TAG, "Mencoba membuka alarm: $hour:$minute")

                        val alarmIntent = Intent(
                            AlarmClock.ACTION_SET_ALARM
                        ).apply {
                            putExtra(AlarmClock.EXTRA_HOUR, hour)
                            putExtra(AlarmClock.EXTRA_MINUTES, minute)
                            putExtra(AlarmClock.EXTRA_MESSAGE, message)
                            putExtra(AlarmClock.EXTRA_SKIP_UI, false)
                        }

                        startActivity(alarmIntent)

                        Log.d(TAG, "Perintah ACTION_SET_ALARM berhasil dikirim")
                        result.success(true)

                    } catch (e: ActivityNotFoundException) {

                        Log.e(TAG, "ACTION_SET_ALARM tidak ditemukan", e)

                        try {
                            val samsungClockPackage =
                                "com.sec.android.app.clockpackage"

                            val clockIntent =
                                packageManager.getLaunchIntentForPackage(
                                    samsungClockPackage
                                )

                            if (clockIntent != null) {
                                startActivity(clockIntent)
                                result.success(true)
                            } else {
                                result.error(
                                    "NO_CLOCK_APP",
                                    "Aplikasi Jam Samsung tidak ditemukan.",
                                    null
                                )
                            }

                        } catch (fallbackError: Exception) {
                            result.error(
                                "CLOCK_OPEN_FAILED",
                                fallbackError.message
                                    ?: "Gagal membuka aplikasi Jam.",
                                null
                            )
                        }

                    } catch (e: Exception) {
                        Log.e(TAG, "Gagal membuka alarm", e)

                        result.error(
                            "SET_ALARM_FAILED",
                            e.message ?: "Terjadi kesalahan saat membuka alarm.",
                            null
                        )
                    }
                }

                else -> result.notImplemented()
            }
        }
    }
}
