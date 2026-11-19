package com.example.c1_01

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import android.graphics.Color
import androidx.core.net.toUri
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Implementation of App Widget functionality.
 */
class External : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (id in appWidgetIds){
            val views = RemoteViews(context.packageName, R.layout.external)

            views.setTextViewText(R.id.date, widgetData.getString("date", "-"))
            views.setTextViewText(R.id.name, "" + widgetData.getString("name", "-"))
            views.setTextViewText(R.id.modal, "" + widgetData.getString("modal", "-"))
            views.setTextViewText(R.id.hours, "Horas/Mês: " + widgetData.getInt("hours", 0))
            views.setTextViewText(R.id.last, "Última nota: " + widgetData.getInt("last", 0))
            views.setTextViewText(R.id.aver, "Média geral: " + widgetData.getInt("aver", 0))

            views.setInt(R.id.hours, "setBackgroundColor", if (widgetData.getInt("hours", 0) < 8) Color.RED else Color.TRANSPARENT);
            views.setInt(R.id.aver, "setBackgroundColor", if (widgetData.getInt("aver", 0) > 60) Color.GREEN else Color.TRANSPARENT);

            val launch = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (launch !=null){
                launch.data = "ws://time".toUri()
                val pi = PendingIntent.getActivity(
                    context, 0, launch,PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.root, pi)
            }

            appWidgetManager.updateAppWidget(id, views)
        }
    }

}

