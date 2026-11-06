package com.example.oneplus_ios27_theme

import android.content.Context
import android.content.Intent
import android.content.pm.LauncherApps
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.Process
import android.os.UserManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.oneplus.ios27/apps"
    private val backgroundExecutor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun getBackgroundMode(): FlutterActivityLaunchConfigs.BackgroundMode {
        return FlutterActivityLaunchConfigs.BackgroundMode.transparent
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        startPersistenceService()
    }

    private fun startPersistenceService() {
        val serviceIntent = Intent(this, LauncherPersistenceService::class.java)
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(serviceIntent)
            } else {
                startService(serviceIntent)
            }
        } catch (e: Exception) {
            // Log or fallback
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    backgroundExecutor.execute {
                        try {
                            val apps = fetchInstalledApps()
                            mainHandler.post {
                                result.success(apps)
                            }
                        } catch (e: Exception) {
                            mainHandler.post {
                                result.error("QUERY_ERROR", e.localizedMessage, null)
                            }
                        }
                    }
                }
                "launchApp" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName.isNullOrBlank()) {
                        result.error("INVALID_PACKAGE", "Package name cannot be empty", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val launched = launchAppByPackage(packageName)
                        if (launched) {
                            result.success(true)
                        } else {
                            result.error("APP_NOT_FOUND", "Could not find launch intent for $packageName", null)
                        }
                    } catch (e: Exception) {
                        result.error("LAUNCH_FAILED", e.localizedMessage, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun fetchInstalledApps(): List<Map<String, Any?>> {
        val appList = ArrayList<Map<String, Any?>>()
        val currentPackage = packageName

        // Try LauncherApps first (standard for Android 5.0+ and supports work profiles)
        val launcherApps = getSystemService(Context.LAUNCHER_APPS_SERVICE) as? LauncherApps
        val userManager = getSystemService(Context.USER_SERVICE) as? UserManager
        val userProfiles = userManager?.userProfiles ?: listOf(Process.myUserHandle())

        if (launcherApps != null && userProfiles.isNotEmpty()) {
            for (profile in userProfiles) {
                val activities = launcherApps.getActivityList(null, profile)
                for (activity in activities) {
                    val pkg = activity.applicationInfo.packageName
                    if (pkg == currentPackage) continue

                    val label = activity.label.toString()
                    val iconDrawable = activity.getIcon(0)
                    val iconBytes = drawableToByteArray(iconDrawable)

                    val map = HashMap<String, Any?>()
                    map["appName"] = label
                    map["packageName"] = pkg
                    map["activityName"] = activity.name
                    map["icon"] = iconBytes
                    appList.add(map)
                }
            }
        }

        // Fallback to PackageManager queryIntentActivities if LauncherApps returned nothing
        if (appList.isEmpty()) {
            val mainIntent = Intent(Intent.ACTION_MAIN, null).apply {
                addCategory(Intent.CATEGORY_LAUNCHER)
            }
            val resolveInfos = packageManager.queryIntentActivities(
                mainIntent,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    PackageManager.ResolveInfoFlags.of(0)
                } else {
                    0
                }
            )

            for (info in resolveInfos) {
                val pkg = info.activityInfo.packageName
                if (pkg == currentPackage) continue

                val label = info.loadLabel(packageManager).toString()
                val iconDrawable = info.loadIcon(packageManager)
                val iconBytes = drawableToByteArray(iconDrawable)

                val map = HashMap<String, Any?>()
                map["appName"] = label
                map["packageName"] = pkg
                map["activityName"] = info.activityInfo.name
                map["icon"] = iconBytes
                appList.add(map)
            }
        }

        // Sort apps alphabetically by name (case-insensitive)
        appList.sortWith { a, b ->
            val nameA = (a["appName"] as? String) ?: ""
            val nameB = (b["appName"] as? String) ?: ""
            nameA.compareTo(nameB, ignoreCase = true)
        }

        return appList
    }

    private fun drawableToByteArray(drawable: Drawable): ByteArray {
        val size = 192 // Standard icon size for optimal fidelity and performance
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)

        val outputStream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
        return outputStream.toByteArray()
    }

    private fun launchAppByPackage(packageName: String): Boolean {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName) ?: return false
        launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED)
        startActivity(launchIntent)
        return true
    }

    override fun onDestroy() {
        super.onDestroy()
        backgroundExecutor.shutdown()
    }
}
