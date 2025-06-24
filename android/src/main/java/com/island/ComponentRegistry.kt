package com.island

import android.util.Log
import java.lang.ref.WeakReference
import android.view.View

class ComponentRegistry private constructor() {
    private val components: MutableMap<String, String> = mutableMapOf() // componentId -> componentName mapping
    private val viewReferences: MutableMap<String, WeakReference<View>> = mutableMapOf() // componentId -> view reference

    fun registerComponent(id: String, componentName: String) {
        components[id] = componentName
        Log.d("ComponentRegistry", "Registered component: $id -> $componentName")
    }

    fun getComponentName(id: String): String? {
        return components[id]
    }

    fun getComponent(id: String): String? {
        return components[id]
    }

    // Store a reference to a rendered component view
    fun storeViewReference(id: String, view: View) {
        viewReferences[id] = WeakReference(view)
        Log.d("ComponentRegistry", "Stored view reference for: $id")
    }

    // Get the stored view reference
    fun getViewReference(id: String): View? {
        return viewReferences[id]?.get()
    }

    fun clearComponent(id: String) {
        components.remove(id)
        viewReferences.remove(id)
        Log.d("ComponentRegistry", "Cleared component: $id")
    }

    fun getAllComponents(): Map<String, String> {
        return components
    }

    companion object {
        val shared: ComponentRegistry by lazy { ComponentRegistry() }
    }
}