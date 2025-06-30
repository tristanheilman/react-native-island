package com.island

import android.os.Bundle
import android.view.ViewGroup
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.UiThreadUtil
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.ReactRootView
import com.facebook.react.uimanager.UIManagerHelper
import com.facebook.react.uimanager.UIManagerModule
import com.facebook.react.uimanager.common.UIManagerType

import com.txusballesteros.bubbles.BubbleLayout;
import com.txusballesteros.bubbles.BubblesManager;
import com.txusballesteros.bubbles.OnInitializedCallback;

@ReactModule(name = RNIslandModule.NAME)
class RNIslandModule(reactContext: ReactApplicationContext) :
  NativeIslandSpec(reactContext) {

  private lateinit var bubblesManager: BubblesManager;
  private lateinit var bubbleView: BubbleLayout;
  private lateinit var componentRegistry: ComponentRegistry;
  private var reactRootView: ReactRootView? = null;
  private var x: Int = 100;
  private var y: Int = 100;
  private var isExpanded: Boolean = false;

  override fun getName(): String {
    return NAME
  }

  @ReactMethod
  override fun setAppGroup(appGroup: String, promise: Promise) {
    println("setAppGroup: $appGroup")
    // No-op in Android
    // This is only used for iOS to share the images of components
    // between the main app and the widget extension
    promise.resolve(true)
  }

  @ReactMethod
  override fun getIslandList(promise: Promise) {
    try {
      // get list actvity IDs from the component registry
      // this should always only return one activity ID
      println("✅ getIslandList")
      println("✅ componentRegistry: $componentRegistry")
      val activities = componentRegistry.getAllComponents().keys
      println("✅ activities: $activities")

      // Convert to WritableArray for React Native
      val writableArray = com.facebook.react.bridge.Arguments.createArray()
      activities.forEach { activity ->
        writableArray.pushString(activity)
      }

      promise.resolve(writableArray)
    } catch (e: Exception) {
      println("❌ Error in getIslandList: ${e.message}")
      e.printStackTrace()
      promise.reject("GET_ISLAND_LIST_ERROR", "Failed to get island list", e)
    }
  }


  @ReactMethod
  override fun startIslandActivity(data: ReadableMap, promise: Promise) {
    println("startIslandActivity: $data")

    initBubblesManager()

    UiThreadUtil.runOnUiThread {
      try {
        println("✅ Starting bubble creation on UI thread")

        // Initialize component registry if not already done
        if (!::componentRegistry.isInitialized) {
          componentRegistry = ComponentRegistry.shared
          println("✅ Component registry initialized")
        }

        // Create the bubble view if it doesn't exist
        if (!::bubbleView.isInitialized) {
          createBubbleView()
          println("✅ Bubble view created")
        }

        // Create React Native root view for the bubble content
        createReactNativeBubbleContent(data)
        println("✅ React Native content created")

        bubblesManager.addBubble(bubbleView, x, y)
        println("✅ Bubble added to manager")

        // Explicitly resolve the promise
        println("✅ About to resolve promise")
        promise.resolve("bubble-created-successfully")
        println("✅ Promise resolved successfully")

      } catch (e: Exception) {
        println("❌ Error in startIslandActivity: ${e.message}")
        e.printStackTrace()
        println("❌ About to reject promise")
        promise.reject("BUBBLE_ERROR", "Failed to start island activity", e)
        println("❌ Promise rejected")
      }
    }
  }

  private fun createBubbleView() {
    try {
      // Create a bubble layout using the XML layout
      val layoutInflater = android.view.LayoutInflater.from(reactApplicationContext)
      bubbleView = layoutInflater.inflate(R.layout.bubble_layout, null) as BubbleLayout
      bubbleView.layoutParams = ViewGroup.LayoutParams(
        ViewGroup.LayoutParams.WRAP_CONTENT,
        ViewGroup.LayoutParams.WRAP_CONTENT
      )

      // Set up click listener for expand/collapse
      bubbleView.setOnBubbleClickListener(
        BubbleLayout.OnBubbleClickListener { bubble ->
          println("✅ Bubble clicked, current state: ${if (isExpanded) "expanded" else "collapsed"}")
          if (isExpanded) {
            minimizeBubble()
          } else {
            expandBubble()
          }
        }
      )

      // Set up remove listener
      bubbleView.setOnBubbleRemoveListener(
        BubbleLayout.OnBubbleRemoveListener { bubble ->
          println("✅ Bubble removed")
          isExpanded = false
          reactRootView = null
        }
      )

      bubbleView.setShouldStickToWall(true)

      println("✅ BubbleLayout created successfully with click listeners")
    } catch (e: Exception) {
      println("❌ Error creating bubble view: ${e.message}")
      throw e
    }
  }

  private fun initBubblesManager() {
    try {
      if (!::bubblesManager.isInitialized) {
        // Use the Builder pattern for BubblesManager (correct way)
        bubblesManager = BubblesManager.Builder(reactApplicationContext)
            .setTrashLayout(R.layout.bubble_trash_layout)
            .build()
        bubblesManager.initialize()
        println("✅ BubblesManager initialized successfully")
      }
    } catch (e: Exception) {
      println("❌ Error initializing bubbles manager: ${e.message}")
      throw e
    }
  }

  private fun createReactNativeBubbleContent(data: ReadableMap) {
    try {
      val componentId = data.getString("bodyComponentId") ?: "body"
      println("✅ Creating bubble content for component: $componentId")

      // Replicate iOS pre-rendering logic
      preRenderComponent(componentId)

      // Initially show collapsed state (just icon)
      showCollapsedState()

    } catch (e: Exception) {
      println("❌ Error creating React Native content: ${e.message}")
      e.printStackTrace()
      throw e
    }
  }

  private fun preRenderComponent(componentId: String) {
    if (componentId.isEmpty()) return

    UiThreadUtil.runOnUiThread {
      try {
        println("Pre-rendering $componentId component...")

        // First, try to get an existing rendered view (like iOS)
        val existingView = componentRegistry.getViewReference(componentId)
        if (existingView != null) {
          println("✅ Found existing view for component: $componentId")
          captureViewImage(existingView, componentId)
        } else {
          println("❌ No existing view found for component: $componentId, creating fallback")
          createFallbackNativeView(componentId)
        }
        println("================================")
      } catch (e: Exception) {
        println("❌ Error in pre-rendering: ${e.message}")
        e.printStackTrace()
        createFallbackNativeView(componentId)
      }
    }
  }

  private fun captureViewImage(view: android.view.View, componentId: String) {
    try {
      println("🔍 Capturing view image for component: $componentId")
      println(" View class: ${view.javaClass.simpleName}")
      println(" View width: ${view.width}, height: ${view.height}")
      println(" View layout params: ${view.layoutParams}")
      
      // Check if view already has dimensions
      if (view.width > 0 && view.height > 0) {
        println("✅ View already has dimensions: ${view.width}x${view.height}")
      } else {
        println("⚠️ View has no dimensions, setting default size")
        
        // Set a default size for the view before measuring
        val defaultWidth = 300
        val defaultHeight = 200
        
        // Set layout params with explicit dimensions
        view.layoutParams = ViewGroup.LayoutParams(defaultWidth, defaultHeight)
        
        // Force layout
        view.requestLayout()
      }
      
      // Wait a bit for layout to complete
      view.post {
        try {
          // Now measure with explicit dimensions
          val widthSpec = android.view.View.MeasureSpec.makeMeasureSpec(
            if (view.width > 0) view.width else 300, 
            android.view.View.MeasureSpec.EXACTLY
          )
          val heightSpec = android.view.View.MeasureSpec.makeMeasureSpec(
            if (view.height > 0) view.height else 200, 
            android.view.View.MeasureSpec.EXACTLY
          )
          
          view.measure(widthSpec, heightSpec)
          view.layout(0, 0, view.measuredWidth, view.measuredHeight)
          
          println("✅ View measured successfully: ${view.measuredWidth}x${view.measuredHeight}")
          
          // Create bitmap with measured dimensions
          val bitmap = android.graphics.Bitmap.createBitmap(
            view.measuredWidth,
            view.measuredHeight,
            android.graphics.Bitmap.Config.ARGB_8888
          )
          val canvas = android.graphics.Canvas(bitmap)
          view.draw(canvas)
          
          // Store the bitmap
          componentImages[componentId] = bitmap
          
          println("✅ Successfully captured existing view for component: $componentId with size: ${bitmap.width}x${bitmap.height}")
          
        } catch (e: Exception) {
          println("❌ Error in post-layout capture: ${e.message}")
          e.printStackTrace()
          createFallbackNativeView(componentId)
        }
      }
      
    } catch (e: Exception) {
      println("❌ Error capturing view image: ${e.message}")
      e.printStackTrace()
      createFallbackNativeView(componentId)
    }
  }

  private fun findAndCaptureExistingView(componentId: String) {
    println("🔍 findAndCaptureExistingView called for componentId: $componentId")

    try {
      // Check if component is registered
      val componentName = componentRegistry.getComponentName(componentId)
      println("✅ Component name from registry: $componentName")

      // Get the current activity's root view
      val currentActivity = reactApplicationContext.currentActivity
      if (currentActivity == null) {
        println("❌ No current activity available")
        createFallbackNativeView(componentId)
        return
      }

      // Find the root view of the current activity
      val rootView = currentActivity.findViewById<android.view.View>(android.R.id.content)
      if (rootView == null) {
        println("❌ No root view found")
        createFallbackNativeView(componentId)
        return
      }

      // Search for views with the component ID as tag
      val targetView = findViewByTag(rootView, componentId)
      if (targetView != null) {
        println("✅ Found existing view for component: $componentId")
        captureViewAsBitmap(targetView, componentId)
      } else {
        println("❌ No existing view found for component: $componentId")
        createFallbackNativeView(componentId)
      }

    } catch (e: Exception) {
      println("❌ Error finding existing view: ${e.message}")
      e.printStackTrace()
      createFallbackNativeView(componentId)
    }
  }

  private fun findViewByTag(root: android.view.View, tag: String): android.view.View? {
    // Check if this view has the tag we're looking for
    if (root.tag != null && root.tag.toString() == tag) {
      return root
    }

    // If it's a ViewGroup, search its children
    if (root is android.view.ViewGroup) {
      for (i in 0 until root.childCount) {
        val child = root.getChildAt(i)
        val result = findViewByTag(child, tag)
        if (result != null) {
          return result
        }
      }
    }

    return null
  }

  private fun captureViewAsBitmap(view: android.view.View, componentId: String) {
    try {
      // Ensure the view is laid out
      view.measure(
        android.view.View.MeasureSpec.makeMeasureSpec(0, android.view.View.MeasureSpec.UNSPECIFIED),
        android.view.View.MeasureSpec.makeMeasureSpec(0, android.view.View.MeasureSpec.UNSPECIFIED)
      )
      view.layout(0, 0, view.measuredWidth, view.measuredHeight)

      // Create bitmap and draw the view
      val bitmap = android.graphics.Bitmap.createBitmap(
        view.measuredWidth,
        view.measuredHeight,
        android.graphics.Bitmap.Config.ARGB_8888
      )
      val canvas = android.graphics.Canvas(bitmap)
      view.draw(canvas)

      // Store the bitmap
      componentImages[componentId] = bitmap
      println("✅ Successfully captured existing view for component: $componentId")

    } catch (e: Exception) {
      println("❌ Error capturing view: ${e.message}")
      e.printStackTrace()
    }
  }

  private fun createFallbackNativeView(componentId: String) {
    // Create a bitmap that looks like your baseball component
    val bitmap = android.graphics.Bitmap.createBitmap(400, 150, android.graphics.Bitmap.Config.ARGB_8888)
    val canvas = android.graphics.Canvas(bitmap)

    // Draw background (green like your component)
    val backgroundPaint = android.graphics.Paint().apply {
      color = android.graphics.Color.parseColor("#4CAF50") // Green
      style = android.graphics.Paint.Style.FILL
    }
    canvas.drawRect(0f, 0f, 400f, 150f, backgroundPaint)

    // Draw text
    val textPaint = android.graphics.Paint().apply {
      color = android.graphics.Color.WHITE
      textSize = 24f
      isAntiAlias = true
      isFakeBoldText = true
    }

    // Draw team info (simulating your baseball component)
    canvas.drawText("KC", 20f, 40f, textPaint)
    canvas.drawText("7", 60f, 40f, textPaint)
    canvas.drawText("LeMoine", 20f, 70f, textPaint)
    canvas.drawText("3.07 ERA", 20f, 100f, textPaint)

    // Draw inning info
    canvas.drawText("Bot 9th 3-2, 2 out", 150f, 70f, textPaint)

    // Draw right team info
    canvas.drawText("SF", 320f, 40f, textPaint)
    canvas.drawText("3", 360f, 40f, textPaint)
    canvas.drawText("Stern", 320f, 70f, textPaint)
    canvas.drawText(".312 AVG", 320f, 100f, textPaint)

    componentImages[componentId] = bitmap
    println("✅ Created fallback native view for component: $componentId")
  }

  // Add this property to store captured images
  private val componentImages = mutableMapOf<String, android.graphics.Bitmap>()

  private fun showCollapsedState() {
    try {
      // Find the notification layout in the inflated XML
      val notificationLayout = bubbleView.findViewById<android.widget.LinearLayout>(R.id.notification_layout)

      if (notificationLayout != null) {
        // Clear existing content
        notificationLayout.removeAllViews()
        // Hide the notification layout
        notificationLayout.visibility = android.view.View.GONE
        println("✅ Notification layout hidden - showing collapsed state")
      }

      isExpanded = false
      println("✅ Bubble collapsed - showing icon only")

    } catch (e: Exception) {
      println("❌ Error showing collapsed state: ${e.message}")
      throw e
    }
  }

  private fun expandBubble() {
    try {
      val notificationLayout = bubbleView.findViewById<android.widget.LinearLayout>(R.id.notification_layout)
  
      if (notificationLayout != null) {
        notificationLayout.removeAllViews()
  
        // Get the component ID
        val componentId = "body" // or get from stored data
  
        // Check if we have a captured image (like iOS widget extension)
        val bitmap = componentImages[componentId]
        if (bitmap != null) {
          // Create an ImageView with the captured content
          val imageView = android.widget.ImageView(reactApplicationContext).apply {
            setImageBitmap(bitmap)
            scaleType = android.widget.ImageView.ScaleType.FIT_XY // Changed from FIT_CENTER
            
            // Set exact dimensions to match the captured component
            layoutParams = ViewGroup.LayoutParams(
              bitmap.width,  // Use exact bitmap width
              bitmap.height  // Use exact bitmap height
            )
          }
          notificationLayout.addView(imageView)
          println("✅ Captured image added to notification layout with exact dimensions: ${bitmap.width}x${bitmap.height}")
        } else {
          // Fallback to text with fixed dimensions
          val fallbackView = android.widget.TextView(reactApplicationContext).apply {
            text = "Component: $componentId\nTap to minimize"
            setTextColor(android.graphics.Color.WHITE)
            setBackgroundColor(android.graphics.Color.BLUE)
            setPadding(20, 20, 20, 20)
            layoutParams = ViewGroup.LayoutParams(
              300, // Fixed width
              150  // Fixed height
            )
          }
          notificationLayout.addView(fallbackView)
          println("✅ Fallback view added to notification layout")
        }
  
        notificationLayout.visibility = android.view.View.VISIBLE
        isExpanded = true
        println("✅ Bubble expanded - showing captured content with exact dimensions")
      }
  
    } catch (e: Exception) {
      println("❌ Error expanding bubble: ${e.message}")
      e.printStackTrace()
      showCollapsedState()
    }
  }

  private fun minimizeBubble() {
    try {
      showCollapsedState()
    } catch (e: Exception) {
      println("❌ Error minimizing bubble: ${e.message}")
      e.printStackTrace()
    }
  }

  private fun createInitialProps(componentId: String): Bundle {
    return Bundle().apply {
      putString("componentId", componentId)
      putString("props", "{}")
    }
  }

  @ReactMethod
  override fun updateIslandActivity(data: ReadableMap, promise: Promise) {
    println("updateIslandActivity: $data")

    try {
      // Run UI operations on the main thread
      UiThreadUtil.runOnUiThread {
        try {
          val componentId = data.getString("bodyComponentId") ?: "body"
          println("✅ Updating island activity for component: $componentId")
          
          // Re-capture the component image (like iOS)
          preRenderComponent(componentId)
          
          // Update the React Native view with new props (if using ReactRootView)
          reactRootView?.setAppProperties(createInitialProps(componentId))
          
          // Update the bubble content if it's expanded
          if (isExpanded) {
            updateExpandedBubbleContent(componentId)
          }
          
          promise.resolve(true)
          println("✅ Island activity updated successfully")
          
        } catch (e: Exception) {
          println("❌ Error updating island activity: ${e.message}")
          e.printStackTrace()
          promise.reject("UPDATE_ERROR", "Failed to update island activity", e)
        }
      }
    } catch (e: Exception) {
      println("❌ Error in updateIslandActivity outer: ${e.message}")
      e.printStackTrace()
      promise.reject("UPDATE_ERROR", "Failed to update island activity", e)
    }
  }

  private fun updateExpandedBubbleContent(componentId: String) {
    try {
      val notificationLayout = bubbleView.findViewById<android.widget.LinearLayout>(R.id.notification_layout)
      
      if (notificationLayout != null) {
        // Clear existing content
        notificationLayout.removeAllViews()
        
        // Get the updated captured image
        val bitmap = componentImages[componentId]
        if (bitmap != null) {
          // Create an ImageView with the updated captured content
          val imageView = android.widget.ImageView(reactApplicationContext).apply {
            setImageBitmap(bitmap)
            scaleType = android.widget.ImageView.ScaleType.FIT_CENTER
            layoutParams = ViewGroup.LayoutParams(
              ViewGroup.LayoutParams.MATCH_PARENT,
              ViewGroup.LayoutParams.WRAP_CONTENT
            )
          }
          notificationLayout.addView(imageView)
          println("✅ Updated bubble content with new captured image")
        } else {
          // Fallback to text
          val fallbackView = android.widget.TextView(reactApplicationContext).apply {
            text = "Updated Component: $componentId\nTap to minimize"
            setTextColor(android.graphics.Color.WHITE)
            setBackgroundColor(android.graphics.Color.BLUE)
            setPadding(20, 20, 20, 20)
            layoutParams = ViewGroup.LayoutParams(
              ViewGroup.LayoutParams.MATCH_PARENT,
              ViewGroup.LayoutParams.WRAP_CONTENT
            )
          }
          notificationLayout.addView(fallbackView)
          println("✅ Updated bubble content with fallback view")
        }
      }
    } catch (e: Exception) {
      println("❌ Error updating expanded bubble content: ${e.message}")
      e.printStackTrace()
    }
  }

  @ReactMethod
  override fun endIslandActivity(promise: Promise) {
    println("endIslandActivity")

    try {
      // Run UI operations on the main thread
      UiThreadUtil.runOnUiThread {
        try {
          // Remove the bubble safely
          if (::bubblesManager.isInitialized) {
            try {
              // Check if bubble view is still attached to window
              if (::bubbleView.isInitialized && bubbleView.windowToken != null) {
                bubblesManager.removeBubble(bubbleView)
                println("✅ Bubble removed successfully")
              } else {
                println("⚠️ Bubble view not attached to window, skipping removal")
              }
            } catch (e: Exception) {
              println("⚠️ Error removing bubble: ${e.message}")
              // Don't fail the promise for bubble removal errors
            }
          }

          // Clean up React Native view
          try {
            reactRootView?.unmountReactApplication()
            reactRootView = null
            println("✅ React Native view cleaned up")
          } catch (e: Exception) {
            println("⚠️ Error cleaning up React Native view: ${e.message}")
          }

          // Clear component registry
          // try {
          //   if (::componentRegistry.isInitialized) {
          //     componentRegistry.getAllComponents().keys.forEach { id ->
          //       componentRegistry.clearComponent(id)
          //     }
          //     println("✅ Component registry cleared")
          //   }
          // } catch (e: Exception) {
          //   println("⚠️ Error clearing component registry: ${e.message}")
          // }

          // Clear captured images
          try {
            componentImages.clear()
            println("✅ Component images cleared")
          } catch (e: Exception) {
            println("⚠️ Error clearing component images: ${e.message}")
          }

          promise.resolve(true)
          println("✅ endIslandActivity completed successfully")
          
        } catch (e: Exception) {
          println("❌ Error in endIslandActivity: ${e.message}")
          e.printStackTrace()
          // Still resolve the promise to avoid hanging
          promise.resolve(false)
        }
      }
    } catch (e: Exception) {
      println("❌ Error in endIslandActivity outer: ${e.message}")
      e.printStackTrace()
      promise.resolve(false)
    }
  }

  @ReactMethod
  override fun registerComponent(id: String, componentName: String, promise: Promise) {
    try {
      if (!::componentRegistry.isInitialized) {
        componentRegistry = ComponentRegistry.shared
      }
      componentRegistry.registerComponent(id, componentName)
      println("✅ Registered component: $id -> $componentName")
      promise.resolve(id)
    } catch (e: Exception) {
      println("❌ Error registering component: ${e.message}")
      promise.reject("REGISTER_ERROR", "Failed to register component", e)
    }
  }

  private fun getUIManager(): Any? {
    return try {
      // Try New Architecture first
      UIManagerHelper.getUIManager(reactApplicationContext, UIManagerType.FABRIC)
    } catch (e: Exception) {
      try {
        // Fallback to Old Architecture
        reactApplicationContext.getNativeModule(UIManagerModule::class.java)
      } catch (e2: Exception) {
        null
      }
    }
  }

  @ReactMethod
  override fun storeViewReference(componentId: String, nodeHandle: Double, promise: Promise) {
    try {
      if (!::componentRegistry.isInitialized) {
        componentRegistry = ComponentRegistry.shared
      }

      // Store the nodeHandle
      componentRegistry.storeNodeHandle(componentId, nodeHandle.toInt())
      println("✅ Stored nodeHandle for component: $componentId -> $nodeHandle")
      
      // Run UIManager operations on UI thread
      UiThreadUtil.runOnUiThread {
        try {
          val nodeHandleInt = nodeHandle.toInt()
          
          // Use UIManagerHelper to get the UIManager
          val uiManager = UIManagerHelper.getUIManager(reactApplicationContext, UIManagerType.FABRIC)
          if (uiManager != null) {
            // Use the UIManager to resolve the view (now on UI thread)
            val view = uiManager.resolveView(nodeHandleInt)
            if (view != null) {
              componentRegistry.storeViewReference(componentId, view)
              println("✅ Stored actual view reference for component: $componentId using UIManagerHelper")
            } else {
              println("⚠️ Could not resolve view with nodeHandle: $nodeHandleInt")
            }
          } else {
            println("⚠️ Could not get UIManager from UIManagerHelper")
          }
        } catch (e: Exception) {
          println("⚠️ Error storing view reference: ${e.message}")
          // Don't fail the promise, just log the warning
        }
      }
      
      promise.resolve(componentId)
    } catch (e: Exception) {
      println("❌ Error storing view reference: ${e.message}")
      promise.reject("STORE_ERROR", "Failed to store view reference", e)
    }
  }

  @ReactMethod
  override fun clearViewReference(componentId: String, promise: Promise) {
    try {
      if (!::componentRegistry.isInitialized) {
        componentRegistry = ComponentRegistry.shared
      }
      componentRegistry.clearComponent(componentId)
      println("✅ Cleared view reference for component: $componentId")

      // Clear the captured image
      componentImages.remove(componentId)
      println("✅ Cleared captured image for component: $componentId")

      promise.resolve(true)
    } catch (e: Exception) {
      println("❌ Error clearing view reference: ${e.message}")
      promise.reject("CLEAR_ERROR", "Failed to clear view reference", e)
    }
  }

  companion object {
    const val NAME = "RNIsland"
  }
}

