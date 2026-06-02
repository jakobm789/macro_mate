package com.example.macro_mate

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
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
    }
}
