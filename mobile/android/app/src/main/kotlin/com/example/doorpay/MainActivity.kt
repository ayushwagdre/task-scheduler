package com.example.doorpay

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import com.example.doorpay.alarm.AlarmReceiver

class MainActivity : FlutterActivity() {
    private val channelName = "doorpay/android_alarm"
    private val permissionsChannelName = "doorpay/android_permissions"
    private val launchChannelName = "doorpay/launch"
    private val launchStreamChannelName = "doorpay/launch_stream"
    private var pendingPermissionResult: MethodChannel.Result? = null
    private var pendingTaskId: String? = null
    private var launchEventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        pendingTaskId = intent?.getStringExtra(AlarmReceiver.EXTRA_TASK_ID)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleExactAlarm" -> {
                    val taskId = call.argument<String>("taskId") ?: ""
                    val triggerAt = call.argument<Number>("triggerAtEpochMillis")?.toLong() ?: 0L
                    val title = call.argument<String>("title") ?: "Task"
                    if (taskId.isBlank() || triggerAt <= 0L) {
                        result.error("bad_args", "taskId and triggerAtEpochMillis required", null)
                        return@setMethodCallHandler
                    }
                    scheduleExact(taskId, triggerAt, title)
                    result.success(true)
                }
                "cancelAlarm" -> {
                    val taskId = call.argument<String>("taskId") ?: ""
                    if (taskId.isBlank()) {
                        result.error("bad_args", "taskId required", null)
                        return@setMethodCallHandler
                    }
                    cancel(taskId)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, permissionsChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "canScheduleExactAlarms" -> {
                    val am = getSystemService(Context.ALARM_SERVICE) as AlarmManager
                    result.success(am.canScheduleExactAlarms())
                }
                "openExactAlarmSettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
                        intent.data = android.net.Uri.parse("package:$packageName")
                        startActivity(intent)
                    }
                    result.success(true)
                }
                "requestPostNotifications" -> {
                    if (Build.VERSION.SDK_INT < 33) {
                        result.success(true)
                        return@setMethodCallHandler
                    }
                    val granted = ContextCompat.checkSelfPermission(this, android.Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
                    if (granted) {
                        result.success(true)
                        return@setMethodCallHandler
                    }
                    pendingPermissionResult = result
                    ActivityCompat.requestPermissions(this, arrayOf(android.Manifest.permission.POST_NOTIFICATIONS), 5010)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, launchChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "consumeInitialTaskId" -> {
                    val v = pendingTaskId
                    pendingTaskId = null
                    result.success(v)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, launchStreamChannelName).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                launchEventSink = events
            }

            override fun onCancel(arguments: Any?) {
                launchEventSink = null
            }
        })
    }

    private fun scheduleExact(taskId: String, triggerAtEpochMillis: Long, title: String) {
        val am = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, AlarmReceiver::class.java).apply {
            putExtra(AlarmReceiver.EXTRA_TASK_ID, taskId)
            putExtra(AlarmReceiver.EXTRA_TITLE, title)
        }
        val pi = PendingIntent.getBroadcast(
            this,
            taskId.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Best-effort exact alarm. If Android blocks exact alarms, it may be inexact.
        am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtEpochMillis, pi)
    }

    private fun cancel(taskId: String) {
        val am = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, AlarmReceiver::class.java)
        val pi = PendingIntent.getBroadcast(
            this,
            taskId.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        am.cancel(pi)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 5010) {
            val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
            pendingPermissionResult?.success(granted)
            pendingPermissionResult = null
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val taskId = intent.getStringExtra(AlarmReceiver.EXTRA_TASK_ID)
        if (!taskId.isNullOrBlank()) {
            pendingTaskId = taskId
            launchEventSink?.success(taskId)
        }
    }
}
