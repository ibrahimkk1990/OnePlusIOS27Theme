package com.example.oneplus_ios27_theme

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder

class LauncherPersistenceService : Service() {

    companion object {
        const val CHANNEL_ID = "ios27_launcher_persistence_channel"
        const val CHANNEL_NAME = "System Persistence Service"
        const val NOTIFICATION_ID = 2701
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startInForeground()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // START_STICKY tells Android to automatically restart the service
        // if memory pressure forces the process to terminate.
        return START_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val existing = notificationManager.getNotificationChannel(CHANNEL_ID)
            if (existing == null) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    CHANNEL_NAME,
                    NotificationManager.IMPORTANCE_MIN // Silent, lowest priority, completely non-intrusive
                ).apply {
                    description = "Maintains launcher memory priority and responsiveness"
                    setShowBadge(false)
                    enableLights(false)
                    enableVibration(false)
                    lockscreenVisibility = Notification.VISIBILITY_SECRET
                }
                notificationManager.createNotificationChannel(channel)
            }
        }
    }

    private fun startInForeground() {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = if (launchIntent != null) {
            PendingIntent.getActivity(
                this,
                0,
                launchIntent,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                } else {
                    PendingIntent.FLAG_UPDATE_CURRENT
                }
            )
        } else {
            null
        }

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        builder.apply {
            setContentTitle("OnePlus iOS27")
            setContentText("Home Launcher is active in memory")
            setSmallIcon(R.mipmap.ic_launcher)
            setOngoing(true)
            if (pendingIntent != null) {
                setContentIntent(pendingIntent)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                setVisibility(Notification.VISIBILITY_SECRET)
                setCategory(Notification.CATEGORY_SERVICE)
            }
            @Suppress("DEPRECATION")
            setPriority(Notification.PRIORITY_MIN)
        }

        startForeground(NOTIFICATION_ID, builder.build())
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        // If destroyed, schedule immediate restart intent
        val restartIntent = Intent(applicationContext, BootReceiver::class.java).apply {
            action = "com.oneplus.ios27.RESTART_SERVICE"
        }
        sendBroadcast(restartIntent)
    }
}
