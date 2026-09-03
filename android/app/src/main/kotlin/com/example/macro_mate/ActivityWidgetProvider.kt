package com.example.macro_mate

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Typeface
import android.os.Build
import android.widget.RemoteViews

class ActivityWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        updateWidgets(context, appWidgetManager, appWidgetIds)
    }

    companion object {
        const val PREFS_NAME = "activity_widget"
        const val KEY_STEPS = "steps"
        const val KEY_STEP_GOAL = "step_goal"
        const val KEY_DISTANCE_KM = "distance_km"
        const val KEY_ACTIVE_CALORIES = "active_calories"
        const val KEY_TOTAL_CALORIES = "total_calories"

        fun updateWidgets(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetIds: IntArray
        ) {
            if (appWidgetIds.isEmpty()) return
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val steps = prefs.getInt(KEY_STEPS, 0)
            val goal = prefs.getInt(KEY_STEP_GOAL, 10000)
            val distanceKm = prefs.getFloat(KEY_DISTANCE_KM, 0f)
            val activeKcal = prefs.getFloat(KEY_ACTIVE_CALORIES, 0f)
            val totalKcal = prefs.getFloat(KEY_TOTAL_CALORIES, 0f)

            for (widgetId in appWidgetIds) {
                val views = RemoteViews(context.packageName, R.layout.activity_widget)
                views.setImageViewBitmap(
                    R.id.activity_widget_image,
                    drawWidgetBitmap(context, steps, goal, distanceKm, activeKcal, totalKcal)
                )
                views.setOnClickPendingIntent(R.id.activity_widget_root, launchIntent(context))
                appWidgetManager.updateAppWidget(widgetId, views)
            }
        }

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, ActivityWidgetProvider::class.java))
            updateWidgets(context, manager, ids)
        }

        private fun launchIntent(context: Context): PendingIntent {
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            return PendingIntent.getActivity(context, 1, intent, flags)
        }

        private fun drawWidgetBitmap(
            context: Context,
            steps: Int,
            goal: Int,
            distanceKm: Float,
            activeKcal: Float,
            totalKcal: Float
        ): Bitmap {
            val density = context.resources.displayMetrics.density
            val size = (148 * density).toInt().coerceAtLeast(148)
            val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            val paint = Paint(Paint.ANTI_ALIAS_FLAG)

            val background = Color.rgb(18, 24, 32)
            val track = Color.rgb(49, 58, 70)
            val stepColor = Color.rgb(38, 166, 154) // Teal
            val activeColor = Color.rgb(255, 112, 67) // Deep Orange
            val textColor = Color.WHITE
            val mutedText = Color.rgb(178, 188, 202)

            // Background
            paint.style = Paint.Style.FILL
            paint.color = background
            canvas.drawRoundRect(
                RectF(0f, 0f, size.toFloat(), size.toFloat()),
                18 * density,
                18 * density,
                paint
            )

            // Step Progress Arc
            val padding = 16 * density
            val stroke = 11 * density
            val rect = RectF(padding, padding, size - padding, size - padding)

            paint.style = Paint.Style.STROKE
            paint.strokeWidth = stroke
            paint.strokeCap = Paint.Cap.ROUND
            paint.color = track
            canvas.drawArc(rect, -90f, 360f, false, paint)

            val progress = if (goal > 0) (steps.toFloat() / goal.toFloat()).coerceIn(0f, 1f) else 0f
            if (progress > 0f) {
                paint.color = stepColor
                canvas.drawArc(rect, -90f, 360f * progress, false, paint)
            }

            // Steps Text (Center)
            paint.style = Paint.Style.FILL
            paint.textAlign = Paint.Align.CENTER
            paint.color = textColor
            paint.typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            paint.textSize = 23 * density
            canvas.drawText(String.format("%,d", steps).replace(',', '.'), size / 2f, size / 2f - 6 * density, paint)

            paint.typeface = Typeface.DEFAULT
            paint.textSize = 10 * density
            paint.color = stepColor
            canvas.drawText(String.format("%.1f km", distanceKm), size / 2f, size / 2f + 11 * density, paint)

            // Active / Total energy
            paint.textSize = 9 * density
            paint.color = activeColor
            val energyStr = if (totalKcal > 0f) {
                "${activeKcal.toInt()} / ${totalKcal.toInt()} kcal"
            } else {
                "${activeKcal.toInt()} kcal aktiv"
            }
            canvas.drawText(energyStr, size / 2f, size / 2f + 27 * density, paint)

            return bitmap
        }
    }
}
