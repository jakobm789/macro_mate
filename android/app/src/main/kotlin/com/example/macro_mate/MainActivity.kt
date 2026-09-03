package com.example.macro_mate

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity(), SensorEventListener {
    private var sensorManager: SensorManager? = null
    private var stepSensor: Sensor? = null
    private var stepEventSink: EventChannel.EventSink? = null
    private var lastRawStepCount: Float = 0f

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "macro_mate/widget"
        ).setMethodCallHandler { call, result ->
            if (call.method != "updateMacroWidget") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val prefs = getSharedPreferences(MacroWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit()
                .putFloat(
                    MacroWidgetProvider.KEY_CONSUMED_CALORIES,
                    (call.argument<Number>("consumedCalories") ?: 0).toFloat()
                )
                .putInt(
                    MacroWidgetProvider.KEY_DAILY_GOAL,
                    (call.argument<Number>("dailyCalorieGoal") ?: 0).toInt()
                )
                .putFloat(
                    MacroWidgetProvider.KEY_CARBS,
                    (call.argument<Number>("consumedCarbs") ?: 0).toFloat()
                )
                .putFloat(
                    MacroWidgetProvider.KEY_PROTEIN,
                    (call.argument<Number>("consumedProtein") ?: 0).toFloat()
                )
                .putFloat(
                    MacroWidgetProvider.KEY_FAT,
                    (call.argument<Number>("consumedFat") ?: 0).toFloat()
                )
                .apply()

            val appWidgetManager = AppWidgetManager.getInstance(this)
            val widgetIds = appWidgetManager.getAppWidgetIds(
                ComponentName(this, MacroWidgetProvider::class.java)
            )
            MacroWidgetProvider.updateWidgets(this, appWidgetManager, widgetIds)
            result.success(null)
        }

        // Native Hardware Step Sensor Integration
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as? SensorManager
        stepSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "macro_mate/step_sensor"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isSensorAvailable" -> {
                    result.success(stepSensor != null)
                }
                "hasPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        val granted = ContextCompat.checkSelfPermission(
                            this,
                            android.Manifest.permission.ACTIVITY_RECOGNITION
                        ) == PackageManager.PERMISSION_GRANTED
                        result.success(granted)
                    } else {
                        result.success(true)
                    }
                }
                "getRawStepCount" -> {
                    if (lastRawStepCount == 0f && stepSensor != null) {
                        sensorManager?.registerListener(
                            this@MainActivity,
                            stepSensor,
                            SensorManager.SENSOR_DELAY_NORMAL
                        )
                    }
                    result.success(lastRawStepCount.toInt())
                }

                else -> result.notImplemented()
            }
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "macro_mate/step_sensor_events"
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                stepEventSink = events
                stepSensor?.let {
                    sensorManager?.registerListener(
                        this@MainActivity,
                        it,
                        SensorManager.SENSOR_DELAY_NORMAL
                    )
                }
            }

            override fun onCancel(arguments: Any?) {
                sensorManager?.unregisterListener(this@MainActivity)
                stepEventSink = null
            }
        })
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type == Sensor.TYPE_STEP_COUNTER && event.values.isNotEmpty()) {
            val steps = event.values[0]
            lastRawStepCount = steps
            stepEventSink?.success(steps.toInt())
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        // Not needed for step counter
    }
}
