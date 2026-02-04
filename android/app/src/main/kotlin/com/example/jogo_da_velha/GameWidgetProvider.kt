package com.example.jogo_da_velha

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews

class GameWidgetProvider : AppWidgetProvider() {
    companion object {
        private const val PREFS_NAME = "game_widget_prefs"
        private const val KEY_MAX_ROUNDS = "widget_max_rounds"
        private const val KEY_TIME_LIMIT = "widget_time_limit"
        private const val DEFAULT_MAX_ROUNDS = 5
        private const val DEFAULT_TIME_LIMIT = 10
        
        private const val ACTION_INCREASE_ROUNDS = "com.example.jogo_da_velha.INCREASE_ROUNDS"
        private const val ACTION_DECREASE_ROUNDS = "com.example.jogo_da_velha.DECREASE_ROUNDS"
        private const val ACTION_INCREASE_TIME = "com.example.jogo_da_velha.INCREASE_TIME"
        private const val ACTION_DECREASE_TIME = "com.example.jogo_da_velha.DECREASE_TIME"
    }

    override fun onEnabled(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        if (!prefs.contains(KEY_MAX_ROUNDS)) {
            prefs.edit()
                .putInt(KEY_MAX_ROUNDS, DEFAULT_MAX_ROUNDS)
                .putInt(KEY_TIME_LIMIT, DEFAULT_TIME_LIMIT)
                .apply()
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val maxRounds = prefs.getInt(KEY_MAX_ROUNDS, DEFAULT_MAX_ROUNDS)
        val timeLimit = prefs.getInt(KEY_TIME_LIMIT, DEFAULT_TIME_LIMIT)

        val views = RemoteViews(context.packageName, R.layout.widget_game)
        
        // Exibe valores
        views.setTextViewText(R.id.widget_max_rounds_value, maxRounds.toString())
        views.setTextViewText(R.id.widget_time_limit_value, timeLimit.toString())

        // Botões para aumentar/diminuir rodadas (desabilita nos limites)
        if (maxRounds < 20) {
            views.setOnClickPendingIntent(
                R.id.widget_increase_rounds,
                createPendingIntent(context, ACTION_INCREASE_ROUNDS, appWidgetId)
            )
            views.setInt(R.id.widget_increase_rounds, "setAlpha", 255)
        } else {
            views.setOnClickPendingIntent(R.id.widget_increase_rounds, null)
            views.setInt(R.id.widget_increase_rounds, "setAlpha", 128)
        }
        
        if (maxRounds > 1) {
            views.setOnClickPendingIntent(
                R.id.widget_decrease_rounds,
                createPendingIntent(context, ACTION_DECREASE_ROUNDS, appWidgetId)
            )
            views.setInt(R.id.widget_decrease_rounds, "setAlpha", 255)
        } else {
            views.setOnClickPendingIntent(R.id.widget_decrease_rounds, null)
            views.setInt(R.id.widget_decrease_rounds, "setAlpha", 128)
        }

        // Botões para aumentar/diminuir tempo (desabilita nos limites)
        if (timeLimit < 60) {
            views.setOnClickPendingIntent(
                R.id.widget_increase_time,
                createPendingIntent(context, ACTION_INCREASE_TIME, appWidgetId)
            )
            views.setInt(R.id.widget_increase_time, "setAlpha", 255)
        } else {
            views.setOnClickPendingIntent(R.id.widget_increase_time, null)
            views.setInt(R.id.widget_increase_time, "setAlpha", 128)
        }
        
        if (timeLimit > 5) {
            views.setOnClickPendingIntent(
                R.id.widget_decrease_time,
                createPendingIntent(context, ACTION_DECREASE_TIME, appWidgetId)
            )
            views.setInt(R.id.widget_decrease_time, "setAlpha", 255)
        } else {
            views.setOnClickPendingIntent(R.id.widget_decrease_time, null)
            views.setInt(R.id.widget_decrease_time, "setAlpha", 128)
        }

        // Botão iniciar jogo (deep link)
        val deepLinkUri = Uri.parse("jogodavelha://local-game?maxRounds=$maxRounds&timeLimitSeconds=$timeLimit")
        val startIntent = Intent(Intent.ACTION_VIEW, deepLinkUri).apply {
            setPackage(context.packageName)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        views.setOnClickPendingIntent(
            R.id.widget_start_game,
            PendingIntent.getActivity(
                context,
                0,
                startIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        )

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun createPendingIntent(context: Context, action: String, appWidgetId: Int): PendingIntent {
        val intent = Intent(context, GameWidgetProvider::class.java).apply {
            this.action = action
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }
        return PendingIntent.getBroadcast(
            context,
            appWidgetId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        val appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) return

        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        var maxRounds = prefs.getInt(KEY_MAX_ROUNDS, DEFAULT_MAX_ROUNDS)
        var timeLimit = prefs.getInt(KEY_TIME_LIMIT, DEFAULT_TIME_LIMIT)

        when (intent.action) {
            ACTION_INCREASE_ROUNDS -> {
                if (maxRounds < 20) {
                    maxRounds++
                    prefs.edit().putInt(KEY_MAX_ROUNDS, maxRounds).apply()
                }
            }
            ACTION_DECREASE_ROUNDS -> {
                if (maxRounds > 1) {
                    maxRounds--
                    prefs.edit().putInt(KEY_MAX_ROUNDS, maxRounds).apply()
                }
            }
            ACTION_INCREASE_TIME -> {
                if (timeLimit < 60) {
                    timeLimit++
                    prefs.edit().putInt(KEY_TIME_LIMIT, timeLimit).apply()
                }
            }
            ACTION_DECREASE_TIME -> {
                if (timeLimit > 5) {
                    timeLimit--
                    prefs.edit().putInt(KEY_TIME_LIMIT, timeLimit).apply()
                }
            }
        }

        // Atualiza o widget
        val appWidgetManager = AppWidgetManager.getInstance(context)
        updateAppWidget(context, appWidgetManager, appWidgetId)
    }
}
