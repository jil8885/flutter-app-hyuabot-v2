package app.kobuggi.hyuabot.home_widgets

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.widget.RemoteViews
import app.kobuggi.hyuabot.MainActivity
import app.kobuggi.hyuabot.R

class ShuttleHomeWidget : AppWidgetProvider() {
    val SHARED_PRES = "prefs"
    val SHUTTLE_STOP = "auto"

    override fun onAppWidgetOptionsChanged(context: Context?, appWidgetManager: AppWidgetManager?, appWidgetId: Int, newOptions: Bundle?) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
    }

    override fun onUpdate(context: Context?, appWidgetManager: AppWidgetManager?, appWidgetIds: IntArray?) {
        if (appWidgetIds != null) {
            for (appWidgetID : Int in appWidgetIds){
                val intent = Intent(context, MainActivity::class.java)
                val pendingIntent = PendingIntent.getActivity(context, 0, intent, 0)

                val prefs: SharedPreferences = context!!.getSharedPreferences(SHARED_PRES, Context.MODE_PRIVATE)
                val buttonText: String = prefs.getString(SHUTTLE_STOP + appWidgetID, "default")!!
                val views = RemoteViews(context.packageName, R.layout.shuttle_widget)
                views.setOnClickPendingIntent(R.id.button, pendingIntent)
                views.setCharSequence(R.id.button, "setText", buttonText)
                appWidgetManager!!.updateAppWidget(appWidgetID, views)
            }
        }
    }
}