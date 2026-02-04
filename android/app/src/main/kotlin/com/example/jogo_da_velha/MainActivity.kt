package com.example.jogo_da_velha

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "br.com.kalebemisael.jogodavelha/deeplink"
    private val prefsKeyRoute = "pending_deeplink_route"
    private val prefsKeyMaxRounds = "pending_deeplink_maxRounds"
    private val prefsKeyTimeLimit = "pending_deeplink_timeLimit"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "getPendingRoute") {
                    val prefs = getSharedPreferences("deeplink_prefs", MODE_PRIVATE)
                    val route = prefs.getString(prefsKeyRoute, null)
                    val maxRounds = prefs.getInt(prefsKeyMaxRounds, 0)
                    val timeLimit = prefs.getInt(prefsKeyTimeLimit, 0)

                    // Limpa os valores após ler
                    prefs.edit()
                        .remove(prefsKeyRoute)
                        .remove(prefsKeyMaxRounds)
                        .remove(prefsKeyTimeLimit)
                        .apply()

                    if (route != null) {
                        val resultMap = mapOf(
                            "route" to route,
                            "maxRounds" to if (maxRounds > 0) maxRounds else 5,
                            "timeLimitSeconds" to if (timeLimit > 0) timeLimit else 10
                        )
                        result.success(resultMap)
                    } else {
                        result.success(null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        val data: Uri? = intent?.data
        if (data != null) {
            saveDeepLink(data)
        }
    }

    private fun saveDeepLink(uri: Uri) {
        if (uri.scheme != "jogodavelha") return

        val prefs = getSharedPreferences("deeplink_prefs", MODE_PRIVATE)
        val host = uri.host

        when (host) {
            "local-game" -> {
                val maxRounds = uri.getQueryParameter("maxRounds")?.toIntOrNull() ?: 5
                val timeLimit = uri.getQueryParameter("timeLimitSeconds")?.toIntOrNull() ?: 10

                prefs.edit()
                    .putString(prefsKeyRoute, "local-game")
                    .putInt(prefsKeyMaxRounds, maxRounds)
                    .putInt(prefsKeyTimeLimit, timeLimit)
                    .apply()
            }
        }
    }
}
