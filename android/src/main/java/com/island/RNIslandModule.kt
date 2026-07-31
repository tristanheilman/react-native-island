package com.island

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.os.Build
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.UiThreadUtil
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.UIManagerHelper
import com.facebook.react.uimanager.common.UIManagerType

/**
 * Android implementation of react-native-island.
 *
 * Android's analog to an iOS Live Activity is an ongoing, updatable
 * notification. Each registered "slot" component is snapshotted from its
 * on-screen React Native view into a Bitmap and placed into the notification's
 * custom (collapsed + expanded) content views. Updates re-snapshot and re-post
 * the same notification id. This mirrors the iOS snapshot approach so the same
 * JS API drives both platforms.
 */
@ReactModule(name = RNIslandModule.NAME)
class RNIslandModule(reactContext: ReactApplicationContext) :
  NativeIslandSpec(reactContext) {

  private val componentRegistry = ComponentRegistry.shared
  private val activeIds = mutableSetOf<Int>()
  private var idCounter = 1000

  override fun getName(): String = NAME

  // --- App group (iOS-only concept; no-op on Android) -----------------------

  @ReactMethod
  override fun setAppGroup(appGroup: String, promise: Promise) {
    promise.resolve(true)
  }

  // --- Component registry ----------------------------------------------------

  @ReactMethod
  override fun registerComponent(id: String, componentName: String, promise: Promise) {
    try {
      componentRegistry.registerComponent(id, componentName)
      promise.resolve(id)
    } catch (e: Exception) {
      promise.reject("REGISTER_ERROR", "Failed to register component", e)
    }
  }

  @ReactMethod
  override fun storeViewReference(componentId: String, nodeHandle: Double, promise: Promise) {
    try {
      componentRegistry.storeNodeHandle(componentId, nodeHandle.toInt())
      UiThreadUtil.runOnUiThread {
        try {
          val uiManager = UIManagerHelper.getUIManager(reactApplicationContext, UIManagerType.FABRIC)
          val view = uiManager?.resolveView(nodeHandle.toInt())
          if (view != null) {
            componentRegistry.storeViewReference(componentId, view)
          } else {
            Log.w(TAG, "Could not resolve view for '$componentId' (nodeHandle=$nodeHandle)")
          }
        } catch (e: Exception) {
          Log.w(TAG, "Error resolving view for '$componentId': ${e.message}")
        }
      }
      promise.resolve(componentId)
    } catch (e: Exception) {
      promise.reject("STORE_ERROR", "Failed to store view reference", e)
    }
  }

  @ReactMethod
  override fun clearViewReference(componentId: String, promise: Promise) {
    try {
      componentRegistry.clearComponent(componentId)
      promise.resolve(true)
    } catch (e: Exception) {
      promise.reject("CLEAR_ERROR", "Failed to clear view reference", e)
    }
  }

  // --- Activity (notification) lifecycle ------------------------------------

  @ReactMethod
  override fun startIslandActivity(data: ReadableMap, promise: Promise) {
    val id = data.getString("id")?.toIntOrNull() ?: nextId()
    UiThreadUtil.runOnUiThread {
      try {
        postNotification(id, data)
        activeIds.add(id)
        promise.resolve(id.toString())
      } catch (e: Exception) {
        Log.e(TAG, "Error starting activity: ${e.message}")
        promise.reject("ACTIVITY_START_ERROR", "Failed to start island activity", e)
      }
    }
  }

  @ReactMethod
  override fun updateIslandActivity(data: ReadableMap, promise: Promise) {
    val id = data.getString("id")?.toIntOrNull()
    if (id == null) {
      promise.reject("ACTIVITY_ID_REQUIRED", "Activity id is required for update", null as Throwable?)
      return
    }
    UiThreadUtil.runOnUiThread {
      try {
        postNotification(id, data)
        activeIds.add(id)
        promise.resolve(id.toString())
      } catch (e: Exception) {
        Log.e(TAG, "Error updating activity: ${e.message}")
        promise.reject("UPDATE_ERROR", "Failed to update island activity", e)
      }
    }
  }

  @ReactMethod
  override fun endIslandActivity(promise: Promise) {
    try {
      val nm = NotificationManagerCompat.from(reactApplicationContext)
      // Cancel the ones we posted, plus any lingering in our channel.
      activeIds.forEach { nm.cancel(it) }
      activeIds.clear()
      promise.resolve(true)
    } catch (e: Exception) {
      promise.reject("END_ERROR", "Failed to end island activity", e)
    }
  }

  @ReactMethod
  override fun getIslandList(promise: Promise) {
    val arr = Arguments.createArray()
    try {
      val nm = reactApplicationContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        nm.activeNotifications
          .filter { it.notification.channelId == CHANNEL_ID }
          .forEach { arr.pushString(it.id.toString()) }
      } else {
        activeIds.forEach { arr.pushString(it.toString()) }
      }
    } catch (e: Exception) {
      Log.w(TAG, "Error getting island list: ${e.message}")
    }
    promise.resolve(arr)
  }

  // --- Internals -------------------------------------------------------------

  private fun nextId(): Int = ++idCounter

  private fun ensureChannel() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      val nm = reactApplicationContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
      if (nm.getNotificationChannel(CHANNEL_ID) == null) {
        val channel = NotificationChannel(
          CHANNEL_ID,
          "Live Activities",
          NotificationManager.IMPORTANCE_DEFAULT
        ).apply {
          description = "Ongoing live activity updates"
          setShowBadge(false)
        }
        nm.createNotificationChannel(channel)
      }
    }
  }

  /** Snapshots a registered on-screen slot view to a Bitmap, or null. */
  private fun captureSlot(componentId: String?): Bitmap? {
    if (componentId.isNullOrEmpty()) return null
    val view = componentRegistry.getViewReference(componentId)
    if (view == null) {
      Log.w(
        TAG,
        "No registered view for '$componentId'. Wrap it in <IslandWrapper " +
          "componentId=\"$componentId\"> and ensure it is mounted before " +
          "starting/updating the activity."
      )
      return null
    }
    return captureViewToBitmap(view)
  }

  private fun captureViewToBitmap(view: View): Bitmap? {
    var width = view.width
    var height = view.height
    if (width <= 0 || height <= 0) {
      view.measure(
        View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED),
        View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
      )
      width = view.measuredWidth
      height = view.measuredHeight
      if (width > 0 && height > 0) view.layout(0, 0, width, height)
    }
    if (width <= 0 || height <= 0) {
      Log.w(TAG, "View has zero size; cannot snapshot")
      return null
    }
    val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(bitmap)
    view.draw(canvas)
    return bitmap
  }

  private fun postNotification(id: Int, data: ReadableMap) {
    ensureChannel()

    val pkg = reactApplicationContext.packageName
    val bodyId = data.getString("bodyComponentId") ?: data.getString("lockScreenComponentId")
    val compactId = data.getString("compactLeadingComponentId") ?: bodyId

    val bodyBitmap = captureSlot(bodyId)
    val compactBitmap = captureSlot(compactId) ?: bodyBitmap

    val builder = NotificationCompat.Builder(reactApplicationContext, CHANNEL_ID)
      .setSmallIcon(R.drawable.ic_island)
      .setOngoing(true)
      .setOnlyAlertOnce(true)
      .setPriority(NotificationCompat.PRIORITY_DEFAULT)
      .setCategory(NotificationCompat.CATEGORY_STATUS)

    if (bodyBitmap != null || compactBitmap != null) {
      val collapsed = RemoteViews(pkg, R.layout.island_notification).apply {
        setImageViewBitmap(R.id.island_image, compactBitmap ?: bodyBitmap)
      }
      val expanded = RemoteViews(pkg, R.layout.island_notification).apply {
        setImageViewBitmap(R.id.island_image, bodyBitmap ?: compactBitmap)
      }
      builder
        .setStyle(NotificationCompat.DecoratedCustomViewStyle())
        .setCustomContentView(collapsed)
        .setCustomBigContentView(expanded)
    } else {
      builder
        .setContentTitle("Live Activity")
        .setContentText("Waiting for content…")
    }

    NotificationManagerCompat.from(reactApplicationContext).notify(id, builder.build())
  }

  companion object {
    const val NAME = "RNIsland"
    private const val TAG = "RNIsland"
    private const val CHANNEL_ID = "island_activities"
  }
}
