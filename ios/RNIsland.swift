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
            // Pre-render React Native components
            preRenderComponent(
                componentId: data["headerComponentId"] as? String ?? "",
                props: data["headerProps"] as? String ?? ""
            )
            
            preRenderComponent(
                componentId: data["bodyComponentId"] as? String ?? "",
                props: data["bodyProps"] as? String ?? ""
            )
            
            preRenderComponent(
                componentId: data["footerComponentId"] as? String ?? "",
                props: data["footerProps"] as? String ?? ""
            )
            
            // Start the activity
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

    private func preRenderComponent(componentId: String, props: String) {
        // Create a React Native view and render it to an image
        // This would be implemented to capture the React Native component
        // and save it as image data to App Group storage
        
        // For now, this is a placeholder
        let userDefaults = UserDefaults(suiteName: "group.your.app.group")
        // In a real implementation, you'd render the React Native component
        // and save it as image data
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

    private func areActivitiesEnabled() -> Bool {
        if #available(iOS 16.2, *) {
            return ActivityAuthorizationInfo.init().areActivitiesEnabled
        } else {
            return false
        }
    }
}
