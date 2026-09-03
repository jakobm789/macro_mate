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
            when (call.method) {
                "updateMacroWidget" -> {
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
                    MacroWidgetProvider.updateAll(this)
                    result.success(null)
                }
                "updateActivityWidget" -> {
                    val prefs = getSharedPreferences(ActivityWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
                    prefs.edit()
                        .putInt(ActivityWidgetProvider.KEY_STEPS, (call.argument<Number>("steps") ?: 0).toInt())
                        .putInt(ActivityWidgetProvider.KEY_STEP_GOAL, (call.argument<Number>("stepGoal") ?: 10000).toInt())
                        .putFloat(ActivityWidgetProvider.KEY_DISTANCE_KM, (call.argument<Number>("distanceKm") ?: 0f).toFloat())
                        .putFloat(ActivityWidgetProvider.KEY_ACTIVE_CALORIES, (call.argument<Number>("activeCalories") ?: 0f).toFloat())
                        .putFloat(ActivityWidgetProvider.KEY_TOTAL_CALORIES, (call.argument<Number>("totalCalories") ?: 0f).toFloat())
                        .apply()
                    ActivityWidgetProvider.updateAll(this)
                    result.success(null)
                }
                "updateWeightWidget" -> {
                    val prefs = getSharedPreferences(WeightWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
                    prefs.edit()
                        .putFloat(WeightWidgetProvider.KEY_CURRENT_WEIGHT, (call.argument<Number>("currentWeight") ?: 0f).toFloat())
                        .putFloat(WeightWidgetProvider.KEY_TREND_KG, (call.argument<Number>("trendKg") ?: 0f).toFloat())
                        .putFloat(WeightWidgetProvider.KEY_TARGET_WEIGHT, (call.argument<Number>("targetWeight") ?: 0f).toFloat())
                        .apply()
                    WeightWidgetProvider.updateAll(this)
                    result.success(null)
                }
                "updateCycleWidget" -> {
                    val prefs = getSharedPreferences(CycleWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
                    prefs.edit()
                        .putInt(CycleWidgetProvider.KEY_CYCLE_DAY, (call.argument<Number>("cycleDay") ?: -1).toInt())
                        .putString(CycleWidgetProvider.KEY_CYCLE_PHASE, call.argument<String>("cyclePhase") ?: "")
                        .putInt(CycleWidgetProvider.KEY_DAYS_UNTIL_NEXT, (call.argument<Number>("daysUntilNext") ?: -1).toInt())
                        .apply()
                    CycleWidgetProvider.updateAll(this)
                    result.success(null)
                }
                "updateOverviewWidget" -> {
                    val prefs = getSharedPreferences(OverviewWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
                    prefs.edit()
                        .putFloat(OverviewWidgetProvider.KEY_CONSUMED_CALORIES, (call.argument<Number>("consumedCalories") ?: 0f).toFloat())
                        .putInt(OverviewWidgetProvider.KEY_DAILY_GOAL, (call.argument<Number>("dailyCalorieGoal") ?: 2000).toInt())
                        .putFloat(OverviewWidgetProvider.KEY_CARBS, (call.argument<Number>("consumedCarbs") ?: 0f).toFloat())
                        .putFloat(OverviewWidgetProvider.KEY_PROTEIN, (call.argument<Number>("consumedProtein") ?: 0f).toFloat())
                        .putFloat(OverviewWidgetProvider.KEY_FAT, (call.argument<Number>("consumedFat") ?: 0f).toFloat())
                        .putInt(OverviewWidgetProvider.KEY_STEPS, (call.argument<Number>("steps") ?: 0).toInt())
                        .putInt(OverviewWidgetProvider.KEY_STEP_GOAL, (call.argument<Number>("stepGoal") ?: 10000).toInt())
                        .putFloat(OverviewWidgetProvider.KEY_DISTANCE_KM, (call.argument<Number>("distanceKm") ?: 0f).toFloat())
                        .putFloat(OverviewWidgetProvider.KEY_ACTIVE_CALORIES, (call.argument<Number>("activeCalories") ?: 0f).toFloat())
                        .putFloat(OverviewWidgetProvider.KEY_TOTAL_CALORIES, (call.argument<Number>("totalCalories") ?: 0f).toFloat())
                        .putFloat(OverviewWidgetProvider.KEY_CURRENT_WEIGHT, (call.argument<Number>("currentWeight") ?: 0f).toFloat())
                        .putFloat(OverviewWidgetProvider.KEY_WEIGHT_TREND, (call.argument<Number>("weightTrend") ?: 0f).toFloat())
                        .putInt(OverviewWidgetProvider.KEY_CYCLE_DAY, (call.argument<Number>("cycleDay") ?: -1).toInt())
                        .putString(OverviewWidgetProvider.KEY_CYCLE_PHASE, call.argument<String>("cyclePhase") ?: "")
                        .apply()
                    OverviewWidgetProvider.updateAll(this)
                    result.success(null)
                }
                "updateAllWidgets" -> {
                    val consumed = (call.argument<Number>("consumedCalories") ?: 0f).toFloat()
                    val goal = (call.argument<Number>("dailyCalorieGoal") ?: 2000).toInt()
                    val carbs = (call.argument<Number>("consumedCarbs") ?: 0f).toFloat()
                    val protein = (call.argument<Number>("consumedProtein") ?: 0f).toFloat()
                    val fat = (call.argument<Number>("consumedFat") ?: 0f).toFloat()

                    val steps = (call.argument<Number>("steps") ?: 0).toInt()
                    val stepGoal = (call.argument<Number>("stepGoal") ?: 10000).toInt()
                    val distanceKm = (call.argument<Number>("distanceKm") ?: 0f).toFloat()
                    val activeKcal = (call.argument<Number>("activeCalories") ?: 0f).toFloat()
                    val totalKcal = (call.argument<Number>("totalCalories") ?: 0f).toFloat()

                    val weight = (call.argument<Number>("currentWeight") ?: 0f).toFloat()
                    val weightTrend = (call.argument<Number>("weightTrend") ?: 0f).toFloat()
                    val targetWeight = (call.argument<Number>("targetWeight") ?: 0f).toFloat()

                    val cycleDay = (call.argument<Number>("cycleDay") ?: -1).toInt()
                    val cyclePhase = call.argument<String>("cyclePhase") ?: ""
                    val daysUntilNext = (call.argument<Number>("daysUntilNext") ?: -1).toInt()

                    // 1. Macro
                    getSharedPreferences(MacroWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE).edit()
                        .putFloat(MacroWidgetProvider.KEY_CONSUMED_CALORIES, consumed)
                        .putInt(MacroWidgetProvider.KEY_DAILY_GOAL, goal)
                        .putFloat(MacroWidgetProvider.KEY_CARBS, carbs)
                        .putFloat(MacroWidgetProvider.KEY_PROTEIN, protein)
                        .putFloat(MacroWidgetProvider.KEY_FAT, fat)
                        .apply()
                    MacroWidgetProvider.updateAll(this)

                    // 2. Activity
                    getSharedPreferences(ActivityWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE).edit()
                        .putInt(ActivityWidgetProvider.KEY_STEPS, steps)
                        .putInt(ActivityWidgetProvider.KEY_STEP_GOAL, stepGoal)
                        .putFloat(ActivityWidgetProvider.KEY_DISTANCE_KM, distanceKm)
                        .putFloat(ActivityWidgetProvider.KEY_ACTIVE_CALORIES, activeKcal)
                        .putFloat(ActivityWidgetProvider.KEY_TOTAL_CALORIES, totalKcal)
                        .apply()
                    ActivityWidgetProvider.updateAll(this)

                    // 3. Weight
                    getSharedPreferences(WeightWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE).edit()
                        .putFloat(WeightWidgetProvider.KEY_CURRENT_WEIGHT, weight)
                        .putFloat(WeightWidgetProvider.KEY_TREND_KG, weightTrend)
                        .putFloat(WeightWidgetProvider.KEY_TARGET_WEIGHT, targetWeight)
                        .apply()
                    WeightWidgetProvider.updateAll(this)

                    // 4. Cycle
                    getSharedPreferences(CycleWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE).edit()
                        .putInt(CycleWidgetProvider.KEY_CYCLE_DAY, cycleDay)
                        .putString(CycleWidgetProvider.KEY_CYCLE_PHASE, cyclePhase)
                        .putInt(CycleWidgetProvider.KEY_DAYS_UNTIL_NEXT, daysUntilNext)
                        .apply()
                    CycleWidgetProvider.updateAll(this)

                    // 5. Overview
                    getSharedPreferences(OverviewWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE).edit()
                        .putFloat(OverviewWidgetProvider.KEY_CONSUMED_CALORIES, consumed)
                        .putInt(OverviewWidgetProvider.KEY_DAILY_GOAL, goal)
                        .putFloat(OverviewWidgetProvider.KEY_CARBS, carbs)
                        .putFloat(OverviewWidgetProvider.KEY_PROTEIN, protein)
                        .putFloat(OverviewWidgetProvider.KEY_FAT, fat)
                        .putInt(OverviewWidgetProvider.KEY_STEPS, steps)
                        .putInt(OverviewWidgetProvider.KEY_STEP_GOAL, stepGoal)
                        .putFloat(OverviewWidgetProvider.KEY_DISTANCE_KM, distanceKm)
                        .putFloat(OverviewWidgetProvider.KEY_ACTIVE_CALORIES, activeKcal)
                        .putFloat(OverviewWidgetProvider.KEY_TOTAL_CALORIES, totalKcal)
                        .putFloat(OverviewWidgetProvider.KEY_CURRENT_WEIGHT, weight)
                        .putFloat(OverviewWidgetProvider.KEY_WEIGHT_TREND, weightTrend)
                        .putInt(OverviewWidgetProvider.KEY_CYCLE_DAY, cycleDay)
                        .putString(OverviewWidgetProvider.KEY_CYCLE_PHASE, cyclePhase)
                        .apply()
                    OverviewWidgetProvider.updateAll(this)

                    result.success(null)
                }
                else -> result.notImplemented()
            }
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
