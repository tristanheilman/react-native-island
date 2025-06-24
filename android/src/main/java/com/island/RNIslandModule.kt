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
      // Get the component ID from the activity data
      val componentId = data.getString("bodyComponentId") ?: "body"
      println("✅ Creating bubble content for component: $componentId")

      // Get the component name from the registry
      val componentName = componentRegistry.getComponentName(componentId)
      println("✅ Component name from registry: $componentName")

      // Create the React Native root view for expanded content
      reactRootView = ReactRootView(reactApplicationContext).apply {
        // Use the component name from registry or fallback to a registered component
        val appName = componentName ?: "BubbleContent" // Use BubbleContent as fallback
        println("✅ Using app name for ReactRootView: $appName")

        // Set the app properties to render the existing component
        setAppProperties(createInitialProps(componentId))

        // Set appropriate size for the expanded bubble
        layoutParams = ViewGroup.LayoutParams(
          ViewGroup.LayoutParams.MATCH_PARENT,
          ViewGroup.LayoutParams.WRAP_CONTENT
        )
      }

      println("✅ ReactRootView created for existing component")

      // Initially show collapsed state (just icon)
      showCollapsedState()

    } catch (e: Exception) {
      println("❌ Error creating React Native content: ${e.message}")
      e.printStackTrace()
      throw e
    }
  }
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
      // Find the notification layout in the inflated XML
      val notificationLayout = bubbleView.findViewById<android.widget.LinearLayout>(R.id.notification_layout)
      
      if (notificationLayout != null) {
        // Clear existing content
        notificationLayout.removeAllViews()
        
        if (reactRootView != null) {
          // Try to add React Native view, but fallback to simple view if it fails
          try {
            notificationLayout.addView(reactRootView)
            println("✅ React Native content added to notification layout")
          } catch (e: Exception) {
            println("❌ Failed to add React Native view, using fallback: ${e.message}")
            
            // Create a fallback view that shows the component name
            val fallbackView = android.widget.TextView(reactApplicationContext).apply {
              val componentName = componentRegistry.getComponentName("body") ?: "Unknown"
              text = "Component: $componentName\nTap to minimize"
              setTextColor(android.graphics.Color.WHITE)
              setBackgroundColor(android.graphics.Color.BLUE)
              setPadding(20, 20, 20, 20)
              layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
              )
            }
            notificationLayout.addView(fallbackView)
            println("✅ Fallback view added to notification layout")
          }
          
          // Show the notification layout
          notificationLayout.visibility = android.view.View.VISIBLE
          isExpanded = true
          println("✅ Bubble expanded - showing React Native content in notification layout")
        } else {
          println("❌ ReactRootView is null, cannot expand")
          showCollapsedState() // Fallback to collapsed state
        }
      } else {
        println("❌ Notification layout not found in XML")
        showCollapsedState() // Fallback to collapsed state
      }

    } catch (e: Exception) {
      println("❌ Error expanding bubble: ${e.message}")
      e.printStackTrace()
      showCollapsedState() // Fallback to collapsed state
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
          // Update the React Native view with new props
          val componentId = data.getString("bodyComponentId") ?: "body"
          reactRootView?.setAppProperties(createInitialProps(componentId))
          promise.resolve(true)
        } catch (e: Exception) {
          promise.reject("UPDATE_ERROR", "Failed to update island activity", e)
        }
      }
    } catch (e: Exception) {
      promise.reject("UPDATE_ERROR", "Failed to update island activity", e)
    }
  }

  @ReactMethod
  override fun endIslandActivity(promise: Promise) {
    println("endIslandActivity")

    try {
      // Run UI operations on the main thread
      UiThreadUtil.runOnUiThread {
        try {
          // Remove the bubble
          if (::bubblesManager.isInitialized) {
            bubblesManager.removeBubble(bubbleView)
          }

          // Clean up React Native view
          reactRootView?.unmountReactApplication()
          reactRootView = null

          // Clear component registry
          componentRegistry.getAllComponents().keys.forEach { id ->
            componentRegistry.clearComponent(id)
          }

          promise.resolve(true)
        } catch (e: Exception) {
          promise.reject("END_ERROR", "Failed to end island activity", e)
        }
      }
    } catch (e: Exception) {
      promise.reject("END_ERROR", "Failed to end island activity", e)
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

  @ReactMethod
  override fun storeViewReference(componentId: String, nodeHandle: Double, promise: Promise) {
    // This method is used to store view references for components
    // Implementation would depend on your specific needs
    println("storeViewReference: $componentId -> $nodeHandle")
    promise.resolve(componentId)
  }

  companion object {
    const val NAME = "RNIsland"
  }
}
