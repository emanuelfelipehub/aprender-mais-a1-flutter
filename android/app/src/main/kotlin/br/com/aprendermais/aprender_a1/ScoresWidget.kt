package br.com.aprendermais.aprender_a1

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

/** Um widget Android real, selecionavel pelo launcher e atualizado ao terminar jogos. */
class ScoresWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        ids.forEach { update(context, manager, it) }
    }
    companion object {
        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            manager.getAppWidgetIds(ComponentName(context, ScoresWidget::class.java))
                .forEach { update(context, manager, it) }
        }
        private fun update(context: Context, manager: AppWidgetManager, id: Int) {
            val prefs = context.getSharedPreferences("a1_scores", Context.MODE_PRIVATE)
            val view = RemoteViews(context.packageName, R.layout.scores_widget)
            view.setTextViewText(R.id.quiz_score, prefs.getInt("quiz", 0).toString())
            view.setTextViewText(R.id.genius_score, prefs.getInt("genius", 0).toString())
            view.setTextViewText(R.id.memo_score, prefs.getInt("memo", 0).toString())
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pending = PendingIntent.getActivity(context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
            view.setOnClickPendingIntent(R.id.widget_root, pending)
            manager.updateAppWidget(id, view)
        }
    }
}

