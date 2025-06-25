package com.island

import android.util.Log
import java.lang.ref.WeakReference
import android.view.View

class ComponentRegistry private constructor() {
    private val components: MutableMap<String, String> = mutableMapOf() // componentId -> componentName mapping
    private val viewReferences: MutableMap<String, WeakReference<View>> = mutableMapOf() // componentId -> view reference
    private val nodeHandles: MutableMap<String, Int> = mutableMapOf() // componentId -> nodeHandle

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

    // Store nodeHandle for a component
    fun storeNodeHandle(id: String, nodeHandle: Int) {
        nodeHandles[id] = nodeHandle
        Log.d("ComponentRegistry", "Stored nodeHandle for: $id -> $nodeHandle")
    }

    // Get the stored nodeHandle
    fun getNodeHandle(id: String): Int? {
        return nodeHandles[id]
    }

    fun clearComponent(id: String) {
        components.remove(id)
        viewReferences.remove(id)
        nodeHandles.remove(id)
        Log.d("ComponentRegistry", "Cleared component: $id")
    }

    fun getAllComponents(): Map<String, String> {
        return components
    }

    companion object {
        val shared: ComponentRegistry by lazy { ComponentRegistry() }
    }
}