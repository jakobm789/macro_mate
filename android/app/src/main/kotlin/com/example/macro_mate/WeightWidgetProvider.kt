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

class WeightWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        updateWidgets(context, appWidgetManager, appWidgetIds)
    }

    companion object {
        const val PREFS_NAME = "weight_widget"
        const val KEY_CURRENT_WEIGHT = "current_weight"
        const val KEY_TREND_KG = "trend_kg"
        const val KEY_TARGET_WEIGHT = "target_weight"

        fun updateWidgets(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetIds: IntArray
        ) {
            if (appWidgetIds.isEmpty()) return
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val currentWeight = prefs.getFloat(KEY_CURRENT_WEIGHT, 0f)
            val trendKg = prefs.getFloat(KEY_TREND_KG, 0f)
            val targetWeight = prefs.getFloat(KEY_TARGET_WEIGHT, 0f)

            for (widgetId in appWidgetIds) {
                val views = RemoteViews(context.packageName, R.layout.weight_widget)
                views.setImageViewBitmap(
                    R.id.weight_widget_image,
                    drawWidgetBitmap(context, currentWeight, trendKg, targetWeight)
                )
                views.setOnClickPendingIntent(R.id.weight_widget_root, launchIntent(context))
                appWidgetManager.updateAppWidget(widgetId, views)
            }
        }

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, WeightWidgetProvider::class.java))
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
            return PendingIntent.getActivity(context, 2, intent, flags)
        }

        private fun drawWidgetBitmap(
            context: Context,
            currentWeight: Float,
            trendKg: Float,
            targetWeight: Float
        ): Bitmap {
            val density = context.resources.displayMetrics.density
            val width = (160 * density).toInt().coerceAtLeast(160)
            val height = (90 * density).toInt().coerceAtLeast(90)
            val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            val paint = Paint(Paint.ANTI_ALIAS_FLAG)

            val background = Color.rgb(18, 24, 32)
            val textColor = Color.WHITE
            val mutedText = Color.rgb(178, 188, 202)
            val accentColor = Color.rgb(65, 155, 245) // Soft Blue
            val successColor = Color.rgb(45, 190, 120) // Green
            val warningColor = Color.rgb(255, 152, 0) // Amber

            // Background
            paint.style = Paint.Style.FILL
            paint.color = background
            canvas.drawRoundRect(
                RectF(0f, 0f, width.toFloat(), height.toFloat()),
                16 * density,
                16 * density,
                paint
            )

            // Header Label
            paint.textAlign = Paint.Align.LEFT
            paint.color = accentColor
            paint.typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            paint.textSize = 10 * density
            canvas.drawText("GEWICHT", 14 * density, 20 * density, paint)

            // Current Weight Value
            paint.color = textColor
            paint.textSize = 22 * density
            val weightStr = if (currentWeight > 0f) String.format("%.1f kg", currentWeight) else "-- kg"
            canvas.drawText(weightStr, 14 * density, 46 * density, paint)

            // Trend
            paint.typeface = Typeface.DEFAULT
            paint.textSize = 10 * density
            if (trendKg != 0f) {
                val trendSign = if (trendKg > 0) "+" else ""
                val trendText = "$trendSign${String.format("%.1f", trendKg)} kg (7 Tage)"
                paint.color = if (trendKg < 0) successColor else warningColor
                canvas.drawText(trendText, 14 * density, 64 * density, paint)
            } else {
                paint.color = mutedText
                canvas.drawText("Kein 7-Tage-Trend", 14 * density, 64 * density, paint)
            }

            // Target or status
            if (targetWeight > 0f) {
                val diff = currentWeight - targetWeight
                val diffSign = if (diff > 0) "+" else ""
                paint.color = mutedText
                paint.textSize = 9 * density
                canvas.drawText("Ziel: ${String.format("%.1f", targetWeight)} kg ($diffSign${String.format("%.1f", diff)} kg)", 14 * density, 78 * density, paint)
            }

            return bitmap
        }
    }
}
