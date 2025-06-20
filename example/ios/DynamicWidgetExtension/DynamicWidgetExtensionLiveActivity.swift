import ActivityKit
import WidgetKit
import SwiftUI

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
            // Lock screen/banner UI goes here
            VStack {
                ReactNativeViewWrapper(componentId: context.state.lockScreenComponentId)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here
                DynamicIslandExpandedRegion(.center, priority: 3, content: {
                    ReactNativeViewWrapper(componentId: context.state.bodyComponentId)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                })
            } compactLeading: {
                // Compact leading UI
                ReactNativeViewWrapper(componentId: context.state.compactLeadingComponentId)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } compactTrailing: {
                // Compact trailing UI
                ReactNativeViewWrapper(componentId: context.state.compactTrailingComponentId)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } minimal: {
                // Minimal UI
                ReactNativeViewWrapper(componentId: context.state.minimalComponentId)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
