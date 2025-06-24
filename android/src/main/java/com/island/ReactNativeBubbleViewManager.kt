package com.island

import android.view.View
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.common.MapBuilder
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.views.view.ReactViewGroup

class ReactNativeBubbleViewManager : SimpleViewManager<ReactViewGroup>() {
    override fun getName(): String {
        return "ReactNativeBubbleView"
    }

    override fun createViewInstance(reactContext: ThemedReactContext): ReactViewGroup {
        return ReactViewGroup(reactContext)
    }

    @ReactProp(name = "componentId")
    fun setComponentId(view: ReactViewGroup, componentId: String) {
        // Store the component ID for later reference
        view.tag = componentId.hashCode()
    }

    @ReactProp(name = "props")
    fun setProps(view: ReactViewGroup, props: ReadableMap?) {
        // Handle props if needed
    }

    override fun getExportedCustomDirectEventTypeConstants(): Map<String, Any>? {
        return MapBuilder.builder<String, Any>()
            .put("onPress", MapBuilder.of("registrationName", "onPress"))
            .build()
    }
}