import Foundation
import React
import UIKit
import AVFoundation
import ActivityKit

@objc(RNIsland)
class RNIsland: RCTEventEmitter {
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
        print("Registered component: \(componentId) -> \(componentName)")
        resolve(componentId)
    }

    @objc
    @available(iOS 16.2, *)
    func startIslandActivity(_ data: [String: Any]) {
        if areActivitiesEnabled() {
            // Debug each component
            let components = [
                ("header", data["headerComponentId"] as? String ?? "", data["headerProps"] as? String ?? ""),
                ("body", data["bodyComponentId"] as? String ?? "", data["bodyProps"] as? String ?? ""),
                ("footer", data["footerComponentId"] as? String ?? "", data["footerProps"] as? String ?? "")
            ]
            
            for (type, componentId, props) in components {
                if !componentId.isEmpty {
                    print("Pre-rendering \(type) component...")
                    debugComponentRendering(componentId: componentId, props: props)
                    preRenderComponent(componentId: componentId, props: props)
                }
            }
            
            // Start the activity after a delay to allow pre-rendering
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                let attributes = DynamicWidgetExtensionAttributes.ContentState(
                    headerComponentId: data["headerComponentId"] as? String ?? "",
                    headerProps: data["headerProps"] as? String ?? "",
                    bodyComponentId: data["bodyComponentId"] as? String ?? "",
                    bodyProps: data["bodyProps"] as? String ?? "",
                    footerComponentId: data["footerComponentId"] as? String ?? "",
                    footerProps: data["footerProps"] as? String ?? ""
                )
                
                do {
                    let activity = try Activity.request(
                        attributes: DynamicWidgetExtensionAttributes(),
                        contentState: attributes
                    )
                    print("Activity started with ID: \(activity.id)")
                } catch {
                    print("Error starting activity: \(error)")
                }
            }
        }
    }

    private func preRenderComponent(componentId: String, props: String) {
        guard !componentId.isEmpty else { return }
        
        DispatchQueue.main.async {
            // First, try to get an existing rendered view
            if let existingView = ComponentRegistry.shared.getViewReference(id: componentId) {
                print("Found existing view for component: \(componentId)")
                self.captureViewImage(existingView, componentId: componentId)
            } else {
                print("No existing view found for component: \(componentId), creating new one")
                self.createAndRenderComponent(componentId: componentId, props: props)
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
            print("Error: Failed to convert image to data for component: \(componentId)")
            return
        }
        
        // Save to App Group storage
        let userDefaults = UserDefaults(suiteName: "group.island.example")
        userDefaults?.set(imageData, forKey: "rendered_\(componentId)")
        userDefaults?.synchronize()
        
        print("Successfully captured existing view for component: \(componentId) with size: \(image.size)")
    }

    private func createAndRenderComponent(componentId: String, props: String) {
        // Fallback to creating a new view (your existing implementation)
        guard let bridge = RCTBridge.current() else {
            print("Error: No React Native bridge available")
            return
        }
        
        // Create a temporary root view for rendering
        let rootView = RCTRootView(
            bridge: bridge,
            moduleName: "DynamicLiveActivity",
            initialProperties: [
                "componentId": componentId,
                "props": props
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
                print("Error: Failed to convert image to data for component: \(componentId)")
                return
            }
            
            // Save to App Group storage
            let userDefaults = UserDefaults(suiteName: "group.island.example")
            userDefaults?.set(imageData, forKey: "rendered_\(componentId)")
            userDefaults?.synchronize()
            
            print("Successfully pre-rendered component: \(componentId) with size: \(image.size)")
            
            // Clean up
            tempWindow.isHidden = true
            rootView.removeFromSuperview()
        }
    }

    @objc
    @available(iOS 16.2, *)
    func updateIslandActivity(_ data: [String: Any]) {
        if areActivitiesEnabled() {
            guard let activityId = data["id"] as? String else {
                print("Error: Activity ID is required for update")
                return
            }
            
            // Find the activity by ID
            if let activity = Activity<DynamicWidgetExtensionAttributes>.activities.first(where: { $0.id == activityId }) {
                let headerComponentId = data["headerComponentId"] as? String ?? activity.content.state.headerComponentId
                let headerProps = data["headerProps"] as? String ?? activity.content.state.headerProps
                let bodyComponentId = data["bodyComponentId"] as? String ?? activity.content.state.bodyComponentId
                let bodyProps = data["bodyProps"] as? String ?? activity.content.state.bodyProps
                let footerComponentId = data["footerComponentId"] as? String ?? activity.content.state.footerComponentId
                let footerProps = data["footerProps"] as? String ?? activity.content.state.footerProps
                
                let contentState = DynamicWidgetExtensionAttributes.ContentState(
                    headerComponentId: headerComponentId,
                    headerProps: headerProps,
                    bodyComponentId: bodyComponentId,
                    bodyProps: bodyProps,
                    footerComponentId: footerComponentId,
                    footerProps: footerProps
                )
                //let activityContent = ActivityContent(state: contentState, staleDate: nil)
                
                // Update the activity
                Task {
                    await activity.update(using: contentState)
                }
            }
        }
    }

    @objc
    @available(iOS 16.2, *)
    func endIslandActivity() {
        if areActivitiesEnabled() {
            let activities = Activity<DynamicWidgetExtensionAttributes>.activities
            for activity in activities {
                Task {
                    await activity.end(dismissalPolicy: .immediate)
                }
            }
        }
    }

    @objc
    func storeViewReference(_ componentId: String, nodeHandle: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            // Find the view by node handle
            if let view = self.bridge?.uiManager.view(forReactTag: nodeHandle) {
                ComponentRegistry.shared.storeViewReference(id: componentId, view: view)
                print("Stored view reference for component: \(componentId)")
                resolve(componentId)
            } else {
                reject("VIEW_NOT_FOUND", "Could not find view for node handle: \(nodeHandle)", nil)
            }
        }
    }

    private func areActivitiesEnabled() -> Bool {
        if #available(iOS 16.2, *) {
            return ActivityAuthorizationInfo.init().areActivitiesEnabled
        } else {
            return false
        }
    }

    private func debugComponentRendering(componentId: String, props: String) {
        print("=== Debug Component Rendering ===")
        print("Component ID: \(componentId)")
        print("Props: \(props)")
        
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

        // Check if bridge is valid
        if bridge.isValid {
            print("✅ Bridge is valid")
        } else {
            print("❌ Bridge is NOT valid")
        }

        // Check if bridge is loaded
        if !bridge.isLoading {
            print("✅ Bridge is loaded")
        } else {
            print("❌ Bridge is NOT loaded")
        }
        
        // Check App Group access
        let userDefaults = UserDefaults(suiteName: "group.island.example")
        if userDefaults != nil {
            print("✅ App Group access available")
        } else {
            print("❌ App Group access NOT available")
        }
        
        print("================================")
    }
}
