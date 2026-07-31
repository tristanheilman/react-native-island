import ActivityKit
import WidgetKit
import SwiftUI

// Canonical Live Activity template for react-native-island.
//
// Copy this file (and ReactNativeViewWrapper.swift) into your Widget Extension
// target. Each region renders a pre-rendered snapshot of the matching React
// Native component, keyed by the componentId carried in the activity's
// ContentState. See docs/DYNAMIC_WIDGET_SETUP.md.

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

@available(iOS 16.2, *)
struct DynamicWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DynamicWidgetExtensionAttributes.self) { context in
            // Lock screen / banner UI
            VStack {
                ReactNativeViewWrapper(componentId: context.state.lockScreenComponentId)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.center, priority: 3, content: {
                    ReactNativeViewWrapper(componentId: context.state.bodyComponentId)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                })
            } compactLeading: {
                ReactNativeViewWrapper(componentId: context.state.compactLeadingComponentId)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } compactTrailing: {
                ReactNativeViewWrapper(componentId: context.state.compactTrailingComponentId)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } minimal: {
                ReactNativeViewWrapper(componentId: context.state.minimalComponentId)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
