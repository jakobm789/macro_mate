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
import android.os.Build
import android.widget.RemoteViews
import kotlin.math.min

class MacroWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        updateWidgets(context, appWidgetManager, appWidgetIds)
    }

    companion object {
        const val PREFS_NAME = "macro_widget"
        const val KEY_CONSUMED_CALORIES = "consumed_calories"
        const val KEY_DAILY_GOAL = "daily_goal"
        const val KEY_CARBS = "carbs"
        const val KEY_PROTEIN = "protein"
        const val KEY_FAT = "fat"

        fun updateWidgets(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetIds: IntArray
        ) {
            if (appWidgetIds.isEmpty()) return
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val consumed = prefs.getFloat(KEY_CONSUMED_CALORIES, 0f)
            val goal = prefs.getInt(KEY_DAILY_GOAL, 2000)
            val carbs = prefs.getFloat(KEY_CARBS, 0f)
            val protein = prefs.getFloat(KEY_PROTEIN, 0f)
            val fat = prefs.getFloat(KEY_FAT, 0f)

            for (widgetId in appWidgetIds) {
                val views = RemoteViews(context.packageName, R.layout.macro_widget)
                views.setImageViewBitmap(
                    R.id.macro_widget_image,
                    drawWidgetBitmap(context, consumed, goal, carbs, protein, fat)
                )
                views.setOnClickPendingIntent(R.id.macro_widget_root, launchIntent(context))
                appWidgetManager.updateAppWidget(widgetId, views)
            }
        }

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, MacroWidgetProvider::class.java))
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
            return PendingIntent.getActivity(context, 0, intent, flags)
        }

        private fun drawWidgetBitmap(
            context: Context,
            consumed: Float,
            goal: Int,
            carbs: Float,
            protein: Float,
            fat: Float
        ): Bitmap {
            val density = context.resources.displayMetrics.density
            val size = (148 * density).toInt().coerceAtLeast(148)
            val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            val paint = Paint(Paint.ANTI_ALIAS_FLAG)

            val background = Color.rgb(18, 24, 32)
            val track = Color.rgb(49, 58, 70)
            val carbColor = Color.rgb(156, 89, 255)
            val proteinColor = Color.rgb(45, 190, 120)
            val fatColor = Color.rgb(65, 155, 245)
            val textColor = Color.WHITE
            val mutedText = Color.rgb(178, 188, 202)

            paint.style = Paint.Style.FILL
            paint.color = background
            canvas.drawRoundRect(
                RectF(0f, 0f, size.toFloat(), size.toFloat()),
                18 * density,
                18 * density,
                paint
            )

            val padding = 16 * density
            val stroke = 13 * density
            val rect = RectF(padding, padding, size - padding, size - padding)

            paint.style = Paint.Style.STROKE
            paint.strokeWidth = stroke
            paint.strokeCap = Paint.Cap.ROUND
            paint.color = track
            canvas.drawArc(rect, -90f, 360f, false, paint)

            val progress = if (goal > 0) (consumed / goal).coerceIn(0f, 1f) else 0f
            val totalMacroCalories = (carbs * 4f + protein * 4f + fat * 9f).coerceAtLeast(0f)
            val segments = if (totalMacroCalories > 0f) {
                listOf(
                    carbColor to (carbs * 4f / totalMacroCalories),
                    proteinColor to (protein * 4f / totalMacroCalories),
                    fatColor to (fat * 9f / totalMacroCalories),
                )
            } else {
                listOf(proteinColor to 1f)
            }

            var startAngle = -90f
            val totalSweep = 360f * progress
            for ((color, share) in segments) {
                val sweep = min(totalSweep * share, 360f)
                if (sweep <= 0f) continue
                paint.color = color
                canvas.drawArc(rect, startAngle, sweep, false, paint)
                startAngle += sweep
            }

            paint.style = Paint.Style.FILL
            paint.textAlign = Paint.Align.CENTER
            paint.color = textColor
            paint.typeface = android.graphics.Typeface.create(
                android.graphics.Typeface.DEFAULT,
                android.graphics.Typeface.BOLD
            )
            paint.textSize = 25 * density
            canvas.drawText(consumed.toInt().toString(), size / 2f, size / 2f - 4 * density, paint)

            paint.typeface = android.graphics.Typeface.DEFAULT
            paint.textSize = 11 * density
            paint.color = mutedText
            canvas.drawText("/ $goal kcal", size / 2f, size / 2f + 16 * density, paint)

            paint.textSize = 9 * density
            paint.color = Color.rgb(132, 145, 162)
            canvas.drawText("heute", size / 2f, size / 2f + 32 * density, paint)

            return bitmap
        }
    }
}
