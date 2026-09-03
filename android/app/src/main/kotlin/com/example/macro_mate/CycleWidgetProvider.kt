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

class CycleWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        updateWidgets(context, appWidgetManager, appWidgetIds)
    }

    companion object {
        const val PREFS_NAME = "cycle_widget"
        const val KEY_CYCLE_DAY = "cycle_day"
        const val KEY_CYCLE_PHASE = "cycle_phase"
        const val KEY_DAYS_UNTIL_NEXT = "days_until_next"

        fun updateWidgets(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetIds: IntArray
        ) {
            if (appWidgetIds.isEmpty()) return
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val cycleDay = prefs.getInt(KEY_CYCLE_DAY, -1)
            val cyclePhase = prefs.getString(KEY_CYCLE_PHASE, "") ?: ""
            val daysUntilNext = prefs.getInt(KEY_DAYS_UNTIL_NEXT, -1)

            for (widgetId in appWidgetIds) {
                val views = RemoteViews(context.packageName, R.layout.cycle_widget)
                views.setImageViewBitmap(
                    R.id.cycle_widget_image,
                    drawWidgetBitmap(context, cycleDay, cyclePhase, daysUntilNext)
                )
                views.setOnClickPendingIntent(R.id.cycle_widget_root, launchIntent(context))
                appWidgetManager.updateAppWidget(widgetId, views)
            }
        }

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, CycleWidgetProvider::class.java))
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
            return PendingIntent.getActivity(context, 3, intent, flags)
        }

        private fun drawWidgetBitmap(
            context: Context,
            cycleDay: Int,
            cyclePhase: String,
            daysUntilNext: Int
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
            val roseColor = Color.rgb(240, 98, 146) // Soft Pink/Rose

            // Background
            paint.style = Paint.Style.FILL
            paint.color = background
            canvas.drawRoundRect(
                RectF(0f, 0f, width.toFloat(), height.toFloat()),
                16 * density,
                16 * density,
                paint
            )

            // Header
            paint.textAlign = Paint.Align.LEFT
            paint.color = roseColor
            paint.typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            paint.textSize = 10 * density
            canvas.drawText("ZYKLUS", 14 * density, 20 * density, paint)

            if (cycleDay > 0) {
                // Cycle Day
                paint.color = textColor
                paint.textSize = 22 * density
                canvas.drawText("Tag $cycleDay", 14 * density, 46 * density, paint)

                // Phase
                paint.typeface = Typeface.DEFAULT
                paint.textSize = 11 * density
                paint.color = roseColor
                canvas.drawText(cyclePhase.ifEmpty { "Zyklus aktiv" }, 14 * density, 64 * density, paint)

                // Days until next
                if (daysUntilNext >= 0) {
                    paint.color = mutedText
                    paint.textSize = 9 * density
                    val nextText = if (daysUntilNext == 0) "Heute erwartet" else "Nächste in $daysUntilNext Tagen"
                    canvas.drawText(nextText, 14 * density, 78 * density, paint)
                }
            } else {
                paint.color = mutedText
                paint.textSize = 12 * density
                paint.typeface = Typeface.DEFAULT
                canvas.drawText("Keine aktiven Zyklusdaten", 14 * density, 48 * density, paint)
                paint.textSize = 9 * density
                canvas.drawText("Im Zyklus-Tab einrichten", 14 * density, 68 * density, paint)
            }

            return bitmap
        }
    }
}
