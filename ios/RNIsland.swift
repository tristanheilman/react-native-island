import Foundation
import React
import UIKit
import AVFoundation
import ActivityKit

@objc(RNIsland)
class RNIsland: RCTEventEmitter {
    var appGroup: String?

    // Injected by the runtime under the New Architecture (bridgeless).
    // See RCTInstance.mm: any module implementing `setSurfacePresenter:`
    // receives the surface presenter automatically.
    private var injectedSurfacePresenter: RCTSurfacePresenterStub?

    @objc
    func setSurfacePresenter(_ presenter: RCTSurfacePresenterStub) {
        self.injectedSurfacePresenter = presenter
    }

    // Resolves the Fabric (New Arch) surface presenter. Under bridgeless
    // (the New Arch default) the runtime injects it via setSurfacePresenter:.
    private var surfacePresenter: RCTSurfacePresenterStub? {
        return injectedSurfacePresenter
    }

    // Resolves a native UIView from a React tag across architectures.
    // New Arch: RCTSurfacePresenter.findComponentViewWithTag; the wrapper
    // uses collapsable={false} so the view is not flattened away.
    // Old Arch: fall back to the legacy UIManager.
    private func resolveView(reactTag: NSNumber) -> UIView? {
        if let presenter = surfacePresenter {
            if let view = presenter.findComponentView(withTag_DO_NOT_USE_DEPRECATED: reactTag.intValue) {
                return view
            }
        }
        return self.bridge?.uiManager?.view(forReactTag: reactTag)
    }

    override func supportedEvents() -> [String]! {
        return []
    }
    
    override static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    // Instead of overriding constantsToExport, we can use a different method name
    @objc
    func getConstants() -> [String: Any]! {
        return [:]
    }

    @objc
    func setAppGroup(_ appGroup: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        self.appGroup = appGroup
        resolve(true)
    }


    @objc
    @available(iOS 16.1, *)
    func getIslandList(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        if areActivitiesEnabled() {
            // Always use DynamicWidgetExtensionAttributes since we're handling the content dynamically
            let activities = Activity<DynamicWidgetExtensionAttributes>.activities
            let ids = activities.map { (act) -> String in
                return act.id
            }
            resolve(ids)
        } else {
            reject("ACTIVITY_DISABLED", "Activities are disabled", nil)
        }
    }

    @objc
    func registerComponent(_ componentId: String, componentName: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        // Store the component name mapping
        ComponentRegistry.shared.registerComponent(id: componentId, componentName: componentName)
        print("✅ Registered component: \(componentId) -> \(componentName)")
        resolve(componentId)
    }

    @objc
    @available(iOS 16.2, *)
    func startIslandActivity(_ data: [String: String], resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        guard areActivitiesEnabled() else {
            reject("ACTIVITY_DISABLED", "Live Activities are disabled", nil)
            return
        }

        DispatchQueue.main.async {
            // Snapshot every registered slot referenced in `data` before
            // requesting the activity, so the widget has images to display.
            self.renderRegisteredSlots(data)

            let contentState = DynamicWidgetExtensionAttributes.ContentState(
                lockScreenComponentId: data["lockScreenComponentId"] ?? "",
                bodyComponentId: data["bodyComponentId"] ?? "",
                compactLeadingComponentId: data["compactLeadingComponentId"] ?? "",
                compactTrailingComponentId: data["compactTrailingComponentId"] ?? "",
                minimalComponentId: data["minimalComponentId"] ?? ""
            )

            do {
                let activity = try Activity.request(
                    attributes: DynamicWidgetExtensionAttributes(),
                    contentState: contentState
                )
                print("✅ Activity started with ID: \(activity.id)")
                resolve(activity.id)
            } catch {
                print("❌ Error starting activity: \(error)")
                reject("ACTIVITY_START_ERROR", "Error starting activity", error)
            }
        }
    }

    // Returns the component ids referenced by an activity data payload,
    // in slot order, skipping empty/missing slots.
    private func componentIds(from data: [String: String]) -> [String] {
        let slotKeys = [
            "lockScreenComponentId",
            "bodyComponentId",
            "compactLeadingComponentId",
            "compactTrailingComponentId",
            "minimalComponentId",
        ]
        return slotKeys.compactMap { data[$0] }.filter { !$0.isEmpty }
    }

    // Snapshots every registered, on-screen slot view referenced in `data`
    // into the shared App Group so the widget extension can display them.
    // Must be called on the main thread (touches UIKit views).
    private func renderRegisteredSlots(_ data: [String: String]) {
        for id in Set(componentIds(from: data)) {
            if let view = ComponentRegistry.shared.getViewReference(id: id) {
                captureViewImage(view, componentId: id)
            } else {
                print("⚠️ No registered view for component '\(id)'. Wrap it in " +
                      "<IslandWrapper componentId=\"\(id)\"> and ensure it is mounted " +
                      "before starting/updating the activity.")
            }
        }
    }

    private func captureViewImage(_ view: UIView, componentId: String) {
        // Ensure the view is properly laid out
        view.layoutIfNeeded()
        
        // Create image renderer
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        let image = renderer.image { context in
            view.layer.render(in: context.cgContext)
        }
        
        // Convert to PNG data
        guard let imageData = image.pngData() else {
            print("❌ Failed to convert image to data for component: \(componentId)")
            return
        }
        
        // Save to App Group storage
        let userDefaults = UserDefaults(suiteName: self.appGroup)
        userDefaults?.set(imageData, forKey: "rendered_\(componentId)")
        userDefaults?.synchronize()
        
        print("✅ Successfully captured existing view for component: \(componentId) with size: \(image.size)")
    }

    @objc
    @available(iOS 16.2, *)
    func updateIslandActivity(_ data: [String: String], resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        guard areActivitiesEnabled() else {
            reject("ACTIVITY_DISABLED", "Live Activities are disabled", nil)
            return
        }
        guard let activityId = data["id"], !activityId.isEmpty else {
            print("❌ Activity ID is required for update")
            reject("ACTIVITY_ID_REQUIRED", "Activity ID is required for update", nil)
            return
        }

        DispatchQueue.main.async {
            // Re-snapshot the referenced slots with their latest content.
            self.renderRegisteredSlots(data)

            // Find the activity by ID
            guard let activity = Activity<DynamicWidgetExtensionAttributes>.activities.first(where: { $0.id == activityId }) else {
                reject("ACTIVITY_NOT_FOUND", "Activity not found", nil)
                return
            }

            let current = activity.content.state
            let contentState = DynamicWidgetExtensionAttributes.ContentState(
                lockScreenComponentId: data["lockScreenComponentId"] ?? current.lockScreenComponentId,
                bodyComponentId: data["bodyComponentId"] ?? current.bodyComponentId,
                compactLeadingComponentId: data["compactLeadingComponentId"] ?? current.compactLeadingComponentId,
                compactTrailingComponentId: data["compactTrailingComponentId"] ?? current.compactTrailingComponentId,
                minimalComponentId: data["minimalComponentId"] ?? current.minimalComponentId
            )

            Task {
                await activity.update(using: contentState)
            }
            resolve(activityId)
        }
    }

    @objc
    @available(iOS 16.2, *)
    func endIslandActivity(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        if areActivitiesEnabled() {
            let activities = Activity<DynamicWidgetExtensionAttributes>.activities
            for activity in activities {
                Task {
                    print("Ending activity: \(activity.id)")
                    await activity.end(dismissalPolicy: .immediate)
                    print("✅ Activity ended: \(activity.id)")
                }
            }
            resolve(true)
        } else {
            reject("ACTIVITY_DISABLED", "Activities are disabled", nil)
        }
    }

    @objc
    func storeViewReference(_ componentId: String, nodeHandle: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            // Find the view by node handle (New Arch aware)
            if let view = self.resolveView(reactTag: nodeHandle) {
                ComponentRegistry.shared.storeViewReference(id: componentId, view: view)
                print("✅ Stored view reference for component: \(componentId)")
                resolve(componentId)
            } else {
                reject("VIEW_NOT_FOUND", "Could not find view for node handle: \(nodeHandle)", nil)
            }
        }
    }

    @objc
    func clearViewReference(_ componentId: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        ComponentRegistry.shared.clearComponent(id: componentId)
        print("✅ Cleared view reference for component: \(componentId)")
        resolve(componentId)
    }

    private func areActivitiesEnabled() -> Bool {
        if #available(iOS 16.2, *) {
            return ActivityAuthorizationInfo.init().areActivitiesEnabled
        } else {
            return false
        }
    }

}

struct DynamicWidgetExtensionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var bodyComponentId: String
        var lockScreenComponentId: String
        var compactLeadingComponentId: String
        var compactTrailingComponentId: String
        var minimalComponentId: String
        
        init(lockScreenComponentId: String = "",
             bodyComponentId: String = "",
             compactLeadingComponentId: String = "",
             compactTrailingComponentId: String = "",
             minimalComponentId: String = "") {
            self.lockScreenComponentId = lockScreenComponentId
            self.bodyComponentId = bodyComponentId
            self.compactLeadingComponentId = compactLeadingComponentId
            self.compactTrailingComponentId = compactTrailingComponentId
            self.minimalComponentId = minimalComponentId
        }
    }
}