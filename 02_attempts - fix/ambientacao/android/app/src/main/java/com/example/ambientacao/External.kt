package com.example.ambientacao

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews
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
            val views= RemoteViews(context.packageName, R.layout.external)

            views.setTextViewText(R.id.id, "App sem valor: " + widgetData.getString("value", "="))
            views.setInt(R.id.root, "setBackgroundColor", if (true) Color.RED else Color.GREEN)

            val launch = context.packageManager.getLaunchIntentForPackage(context.packageName)

            if (launch !=null){
                launch.data= "ws://time".toUri();
                val pi = PendingIntent.getActivity(context, 0, launch, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
                views.setOnClickPendingIntent(R.id.root, pi)
            }

            appWidgetManager.updateAppWidget(id, views);
        }
    }

}
