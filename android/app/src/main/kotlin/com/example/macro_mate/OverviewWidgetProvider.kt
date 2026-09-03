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
import kotlin.math.min

class OverviewWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        updateWidgets(context, appWidgetManager, appWidgetIds)
    }

    companion object {
        const val PREFS_NAME = "overview_widget"
        const val KEY_CONSUMED_CALORIES = "consumed_calories"
        const val KEY_DAILY_GOAL = "daily_goal"
        const val KEY_CARBS = "carbs"
        const val KEY_PROTEIN = "protein"
        const val KEY_FAT = "fat"
        const val KEY_STEPS = "steps"
        const val KEY_STEP_GOAL = "step_goal"
        const val KEY_DISTANCE_KM = "distance_km"
        const val KEY_ACTIVE_CALORIES = "active_calories"
        const val KEY_TOTAL_CALORIES = "total_calories"
        const val KEY_CURRENT_WEIGHT = "current_weight"
        const val KEY_WEIGHT_TREND = "weight_trend"
        const val KEY_CYCLE_DAY = "cycle_day"
        const val KEY_CYCLE_PHASE = "cycle_phase"

        fun updateWidgets(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetIds: IntArray
        ) {
            if (appWidgetIds.isEmpty()) return
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

            val consumed = prefs.getFloat(KEY_CONSUMED_CALORIES, 0f)
            val calGoal = prefs.getInt(KEY_DAILY_GOAL, 2000)
            val carbs = prefs.getFloat(KEY_CARBS, 0f)
            val protein = prefs.getFloat(KEY_PROTEIN, 0f)
            val fat = prefs.getFloat(KEY_FAT, 0f)

            val steps = prefs.getInt(KEY_STEPS, 0)
            val stepGoal = prefs.getInt(KEY_STEP_GOAL, 10000)
            val distanceKm = prefs.getFloat(KEY_DISTANCE_KM, 0f)
            val activeKcal = prefs.getFloat(KEY_ACTIVE_CALORIES, 0f)
            val totalKcal = prefs.getFloat(KEY_TOTAL_CALORIES, 0f)

            val weight = prefs.getFloat(KEY_CURRENT_WEIGHT, 0f)
            val weightTrend = prefs.getFloat(KEY_WEIGHT_TREND, 0f)
            val cycleDay = prefs.getInt(KEY_CYCLE_DAY, -1)
            val cyclePhase = prefs.getString(KEY_CYCLE_PHASE, "") ?: ""

            for (widgetId in appWidgetIds) {
                val views = RemoteViews(context.packageName, R.layout.overview_widget)
                views.setImageViewBitmap(
                    R.id.overview_widget_image,
                    drawWidgetBitmap(
                        context, consumed, calGoal, carbs, protein, fat,
                        steps, stepGoal, distanceKm, activeKcal, totalKcal,
                        weight, weightTrend, cycleDay, cyclePhase
                    )
                )
                views.setOnClickPendingIntent(R.id.overview_widget_root, launchIntent(context))
                appWidgetManager.updateAppWidget(widgetId, views)
            }
        }

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, OverviewWidgetProvider::class.java))
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
            calGoal: Int,
            carbs: Float,
            protein: Float,
            fat: Float,
            steps: Int,
            stepGoal: Int,
            distanceKm: Float,
            activeKcal: Float,
            totalKcal: Float,
            weight: Float,
            weightTrend: Float,
            cycleDay: Int,
            cyclePhase: String
        ): Bitmap {
            val density = context.resources.displayMetrics.density
            val width = (320 * density).toInt().coerceAtLeast(320)
            val height = (140 * density).toInt().coerceAtLeast(140)
            val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            val paint = Paint(Paint.ANTI_ALIAS_FLAG)

            val background = Color.rgb(18, 24, 32)
            val surfaceSubtle = Color.rgb(28, 35, 46)
            val trackColor = Color.rgb(49, 58, 70)
            val textColor = Color.WHITE
            val mutedText = Color.rgb(178, 188, 202)
            val carbColor = Color.rgb(156, 89, 255)
            val proteinColor = Color.rgb(45, 190, 120)
            val fatColor = Color.rgb(65, 155, 245)
            val stepColor = Color.rgb(38, 166, 154) // Teal
            val activeColor = Color.rgb(255, 112, 67) // Orange
            val roseColor = Color.rgb(240, 98, 146) // Pink

            // Outer rounded background
            paint.style = Paint.Style.FILL
            paint.color = background
            canvas.drawRoundRect(
                RectF(0f, 0f, width.toFloat(), height.toFloat()),
                18 * density,
                18 * density,
                paint
            )

            // Header Banner: App Name & Title
            paint.textAlign = Paint.Align.LEFT
            paint.color = Color.rgb(200, 210, 225)
            paint.typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            paint.textSize = 11 * density
            canvas.drawText("MACROMATE ÜBERBLICK", 14 * density, 18 * density, paint)

            val colWidth = (width - 28 * density) / 3f

            // -------------------------------------------------------------
            // Column 1: ERNÄHRUNG (Calories & Macros)
            // -------------------------------------------------------------
            val col1Left = 14 * density
            val col1Center = col1Left + colWidth / 2f

            // Card background for col 1
            paint.color = surfaceSubtle
            canvas.drawRoundRect(
                RectF(col1Left, 26 * density, col1Left + colWidth - 6 * density, height - 12 * density),
                12 * density,
                12 * density,
                paint
            )

            // Calorie arc
            val arcSize = 36 * density
            val arcLeft = col1Center - arcSize / 2f - 3 * density
            val arcTop = 32 * density
            val arcRect = RectF(arcLeft, arcTop, arcLeft + arcSize, arcTop + arcSize)

            paint.style = Paint.Style.STROKE
            paint.strokeWidth = 4.5f * density
            paint.color = trackColor
            canvas.drawArc(arcRect, -90f, 360f, false, paint)

            val calProgress = if (calGoal > 0) (consumed / calGoal).coerceIn(0f, 1f) else 0f
            if (calProgress > 0f) {
                paint.color = proteinColor
                canvas.drawArc(arcRect, -90f, 360f * calProgress, false, paint)
            }

            paint.style = Paint.Style.FILL
            paint.textAlign = Paint.Align.CENTER
            paint.typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            paint.textSize = 10 * density
            paint.color = textColor
            canvas.drawText("${consumed.toInt()}", col1Center - 3 * density, 52 * density, paint)

            paint.typeface = Typeface.DEFAULT
            paint.textSize = 8 * density
            paint.color = mutedText
            canvas.drawText("von $calGoal kcal", col1Center - 3 * density, 78 * density, paint)

            // Macros line
            paint.textSize = 8 * density
            val macroY = 96 * density
            paint.color = carbColor
            canvas.drawText("K:${carbs.toInt()}g", col1Center - 22 * density, macroY, paint)
            paint.color = proteinColor
            canvas.drawText("P:${protein.toInt()}g", col1Center - 3 * density, macroY, paint)
            paint.color = fatColor
            canvas.drawText("F:${fat.toInt()}g", col1Center + 16 * density, macroY, paint)

            val remaining = (calGoal - consumed.toInt()).coerceAtLeast(0)
            paint.color = mutedText
            paint.textSize = 7.5f * density
            canvas.drawText("Noch $remaining kcal", col1Center - 3 * density, 114 * density, paint)

            // -------------------------------------------------------------
            // Column 2: AKTIVITÄT & ENERGIE (Steps & Energy)
            // -------------------------------------------------------------
            val col2Left = col1Left + colWidth
            val col2Center = col2Left + colWidth / 2f

            paint.color = surfaceSubtle
            canvas.drawRoundRect(
                RectF(col2Left, 26 * density, col2Left + colWidth - 6 * density, height - 12 * density),
                12 * density,
                12 * density,
                paint
            )

            // Step count
            paint.textAlign = Paint.Align.CENTER
            paint.color = stepColor
            paint.typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            paint.textSize = 15 * density
            canvas.drawText(String.format("%,d", steps).replace(',', '.'), col2Center - 3 * density, 48 * density, paint)

            paint.typeface = Typeface.DEFAULT
            paint.color = mutedText
            paint.textSize = 8.5f * density
            canvas.drawText("Schritte (${String.format("%.1f", distanceKm)} km)", col2Center - 3 * density, 62 * density, paint)

            // Small step progress bar
            val barWidth = colWidth - 24 * density
            val barHeight = 4 * density
            val barLeft = col2Center - barWidth / 2f - 3 * density
            val barTop = 70 * density

            paint.color = trackColor
            canvas.drawRoundRect(RectF(barLeft, barTop, barLeft + barWidth, barTop + barHeight), 2 * density, 2 * density, paint)

            val stepProgress = if (stepGoal > 0) (steps.toFloat() / stepGoal.toFloat()).coerceIn(0f, 1f) else 0f
            if (stepProgress > 0f) {
                paint.color = stepColor
                canvas.drawRoundRect(RectF(barLeft, barTop, barLeft + barWidth * stepProgress, barTop + barHeight), 2 * density, 2 * density, paint)
            }

            // Energy rows
            paint.textAlign = Paint.Align.LEFT
            paint.textSize = 8.5f * density
            paint.color = activeColor
            canvas.drawText("🔥 ${activeKcal.toInt()} kcal aktiv", barLeft, 94 * density, paint)

            paint.color = Color.rgb(255, 183, 77) // Amber
            val totalStr = if (totalKcal > 0f) "⚡ ${totalKcal.toInt()} kcal Ges." else "⚡ Gesamtumsatz"
            canvas.drawText(totalStr, barLeft, 112 * density, paint)

            // -------------------------------------------------------------
            // Column 3: KÖRPER & STATUS (Weight & Cycle)
            // -------------------------------------------------------------
            val col3Left = col2Left + colWidth
            val col3Center = col3Left + colWidth / 2f

            paint.color = surfaceSubtle
            canvas.drawRoundRect(
                RectF(col3Left, 26 * density, col3Left + colWidth - 6 * density, height - 12 * density),
                12 * density,
                12 * density,
                paint
            )

            paint.textAlign = Paint.Align.LEFT
            val col3InnerLeft = col3Left + 8 * density

            // Weight section
            paint.color = fatColor
            paint.typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            paint.textSize = 9 * density
            canvas.drawText("GEWICHT", col3InnerLeft, 40 * density, paint)

            paint.color = textColor
            paint.textSize = 14 * density
            val wStr = if (weight > 0f) String.format("%.1f kg", weight) else "-- kg"
            canvas.drawText(wStr, col3InnerLeft, 56 * density, paint)

            paint.typeface = Typeface.DEFAULT
            paint.textSize = 8 * density
            if (weightTrend != 0f) {
                paint.color = if (weightTrend < 0) proteinColor else Color.rgb(255, 152, 0)
                val sign = if (weightTrend > 0) "+" else ""
                canvas.drawText("$sign${String.format("%.1f", weightTrend)} kg/Woche", col3InnerLeft, 69 * density, paint)
            } else {
                paint.color = mutedText
                canvas.drawText("Kein Trend", col3InnerLeft, 69 * density, paint)
            }

            // Cycle or Health Status section
            val dividerY = 76 * density
            paint.color = trackColor
            canvas.drawLine(col3InnerLeft, dividerY, col3Left + colWidth - 14 * density, dividerY, paint)

            if (cycleDay > 0) {
                paint.color = roseColor
                paint.typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
                paint.textSize = 9 * density
                canvas.drawText("ZYKLUS", col3InnerLeft, 90 * density, paint)

                paint.color = textColor
                paint.textSize = 11 * density
                canvas.drawText("Tag $cycleDay", col3InnerLeft, 104 * density, paint)

                paint.color = mutedText
                paint.typeface = Typeface.DEFAULT
                paint.textSize = 7.5f * density
                canvas.drawText(cyclePhase.ifEmpty { "Aktiv" }, col3InnerLeft, 116 * density, paint)
            } else {
                paint.color = Color.rgb(65, 155, 245)
                paint.typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
                paint.textSize = 9 * density
                canvas.drawText("STATUS", col3InnerLeft, 90 * density, paint)

                paint.color = textColor
                paint.textSize = 10 * density
                canvas.drawText("Synchronisiert", col3InnerLeft, 104 * density, paint)

                paint.color = mutedText
                paint.typeface = Typeface.DEFAULT
                paint.textSize = 7.5f * density
                canvas.drawText("Alle Daten lokal", col3InnerLeft, 116 * density, paint)
            }

            return bitmap
        }
    }
}
