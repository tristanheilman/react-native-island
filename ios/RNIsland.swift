import Foundation
import React
import UIKit
import AVFoundation
import ActivityKit

@objc(RNIsland)
class RNIsland: RCTEventEmitter {
    var appGroup: String?

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
        if areActivitiesEnabled() {
            handlePrerendering(data: data)
            
            // Start the activity after a delay to allow pre-rendering
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                let attributes = DynamicWidgetExtensionAttributes.ContentState(
                    lockScreenComponentId: data["lockScreenComponentId"] as? String ?? "",
                    bodyComponentId: data["bodyComponentId"] as? String ?? "",
                    compactLeadingComponentId: data["compactLeadingComponentId"] as? String ?? "",
                    compactTrailingComponentId: data["compactTrailingComponentId"] as? String ?? "",
                    minimalComponentId: data["minimalComponentId"] as? String ?? ""
                )
                
                do {
                    let activity = try Activity.request(
                        attributes: DynamicWidgetExtensionAttributes(),
                        contentState: attributes
                    )
                    print("✅ Activity started with ID: \(activity.id)")
                    resolve(activity.id)
                } catch {
                    print("❌ Error starting activity: \(error)")
                    reject("ACTIVITY_START_ERROR", "Error starting activity", error)
                }
            }
        }
    }

    private func preRenderComponent(componentId: String) {
        guard !componentId.isEmpty else { return }
        
        DispatchQueue.main.async {
            // First, try to get an existing rendered view
            print("Pre-rendering \(componentId) component...")
            if let existingView = ComponentRegistry.shared.getViewReference(id: componentId) {
                print("✅ Found existing view for component: \(componentId)")
                self.captureViewImage(existingView, componentId: componentId)
            } else {
                print("❌ No existing view found for component: \(componentId), creating new one")
                self.createAndRenderComponent(componentId: componentId)
            }
            print("================================")
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

    private func createAndRenderComponent(componentId: String) {
        // Fallback to creating a new view (your existing implementation)
        guard let bridge = RCTBridge.current() else {
            print("❌ No React Native bridge available")
            return
        }
        
        // Create a temporary root view for rendering
        let rootView = RCTRootView(
            bridge: bridge,
            moduleName: "DynamicLiveActivity",
            initialProperties: [
                "componentId": componentId,
                "props": ""
            ]
        )
        
        // Set appropriate size for rendering (adjust based on your needs)
        let renderSize = CGSize(width: 300, height: 200)
        rootView.frame = CGRect(origin: .zero, size: renderSize)
        
        // Ensure the view is added to a window for proper rendering
        let tempWindow = UIWindow(frame: CGRect(origin: .zero, size: renderSize))
        tempWindow.addSubview(rootView)
        tempWindow.makeKeyAndVisible()
        
        // Wait for the React Native component to render
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Create image renderer
            let renderer = UIGraphicsImageRenderer(bounds: rootView.bounds)
            let image = renderer.image { context in
                // Ensure the view is properly laid out
                rootView.layoutIfNeeded()
                rootView.layer.render(in: context.cgContext)
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
            
            print("✅ Successfully pre-rendered component: \(componentId) with size: \(image.size)")
            
            // Clean up
            tempWindow.isHidden = true
            rootView.removeFromSuperview()
        }
    }

    private func handlePrerendering(data: [String: String]) {
        let components = ["lockScreen", "body", "compactTrailing", "compactLeading", "minimal"]
            
        for id in components {
            //debugComponentRendering(componentId: id)
            preRenderComponent(componentId: id)
        }
        
    }

    @objc
    @available(iOS 16.2, *)
    func updateIslandActivity(_ data: [String: String], resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        if areActivitiesEnabled() {
            guard let activityId = data["id"] as? String else {
                print("❌ Activity ID is required for update")
                reject("ACTIVITY_ID_REQUIRED", "Activity ID is required for update", nil)
                return
            }

            handlePrerendering(data: data)
            
            // Find the activity by ID
            if let activity = Activity<DynamicWidgetExtensionAttributes>.activities.first(where: { $0.id == activityId }) {
                let lockScreenComponentId = data["lockScreenComponentId"] as? String ?? activity.content.state.lockScreenComponentId
                let bodyComponentId = data["bodyComponentId"] as? String ?? activity.content.state.bodyComponentId
                let compactLeadingComponentId = data["compactLeadingComponentId"] as? String ?? activity.content.state.compactLeadingComponentId
                let compactTrailingComponentId = data["compactTrailingComponentId"] as? String ?? activity.content.state.compactTrailingComponentId
                let minimalComponentId = data["minimalComponentId"] as? String ?? activity.content.state.minimalComponentId
                
                let contentState = DynamicWidgetExtensionAttributes.ContentState(
                    lockScreenComponentId: lockScreenComponentId,
                    bodyComponentId: bodyComponentId,
                    compactLeadingComponentId: compactLeadingComponentId,
                    compactTrailingComponentId: compactTrailingComponentId,
                    minimalComponentId: minimalComponentId
                )
                //let activityContent = ActivityContent(state: contentState, staleDate: nil)
                
                // Update the activity
                Task {
                    await activity.update(using: contentState)
                }
                resolve(activityId)
            } else {
                reject("ACTIVITY_NOT_FOUND", "Activity not found", nil)
            }
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
            // Find the view by node handle
            if let view = self.bridge?.uiManager.view(forReactTag: nodeHandle) {
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

    private func debugComponentRendering(componentId: String) {
        print("=== Debug Component Rendering ===")
        print("Component ID: \(componentId)")
        
        // Check if component is registered
        if let componentName = ComponentRegistry.shared.getComponentName(id: componentId) {
            print("✅ Component found in registry: \(componentName)")
        } else {
            print("❌ Component NOT found in registry")
        }
        
        // Check bridge availability
        if let bridge = RCTBridge.current() {
            print("✅ React Native bridge available")
        } else {
            print("❌ React Native bridge NOT available")
        }
        
        // Check App Group access
        let userDefaults = UserDefaults(suiteName: self.appGroup)
        if userDefaults != nil {
            print("✅ App Group access available")
        } else {
            print("❌ App Group access NOT available")
        }
        
        print("================================")
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