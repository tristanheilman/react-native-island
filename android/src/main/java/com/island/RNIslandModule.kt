package com.island

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.annotations.ReactModule

@ReactModule(name = RNIslandModule.NAME)
class RNIslandModule(reactContext: ReactApplicationContext) :
  NativeIslandSpec(reactContext) {

  override fun getName(): String {
    return NAME
  }

  @ReactMethod
  fun setAppGroup(appGroup: String) {
    println("setAppGroup: $appGroup")
  }

  @ReactMethod
  fun getIslandList(callback: (List<String>) -> Unit) {
    callback.invoke(listOf("Island 1", "Island 2", "Island 3"))
  }

  @ReactMethod
  fun startIslandActivity(activity: Map<String, Any>) {
    println("startIslandActivity: $activity")
  }

  @ReactMethod
  fun updateIslandActivity(activity: Map<String, Any>) {
    println("updateIslandActivity: $activity")
  }

  @ReactMethod
  fun endIslandActivity() {
    println("endIslandActivity")
  }

  companion object {
    const val NAME = "RNIsland"
  }
}
