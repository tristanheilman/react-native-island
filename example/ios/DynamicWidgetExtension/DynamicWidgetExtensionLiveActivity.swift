import ActivityKit
import WidgetKit
import SwiftUI

struct DynamicWidgetExtensionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var headerComponentId: String
        var bodyComponentId: String
        var footerComponentId: String
        var compactLeadingComponentId: String
        var compactTrailingComponentId: String
        var minimalComponentId: String
        
        init(headerComponentId: String = "",
             bodyComponentId: String = "",
             footerComponentId: String = "",
             compactLeadingComponentId: String = "",
             compactTrailingComponentId: String = "",
             minimalComponentId: String = "") {
            self.headerComponentId = headerComponentId
            self.bodyComponentId = bodyComponentId
            self.footerComponentId = footerComponentId
            self.compactLeadingComponentId = compactLeadingComponentId
            self.compactTrailingComponentId = compactTrailingComponentId
            self.minimalComponentId = minimalComponentId
        }
    }
}

struct DynamicHeaderView: View {
    let componentId: String
    
    var body: some View {
        //Text("Header")
        ReactNativeViewWrapper(componentId: componentId)
            .frame(height: 60)
    }
}

struct DynamicBodyView: View {
    let componentId: String

    var body: some View {
        ReactNativeViewWrapper(componentId: componentId)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct DynamicFooterView: View {
    let componentId: String
    
    var body: some View {
        ReactNativeViewWrapper(componentId: componentId)
            .frame(height: 40)
    }
}

struct DynamicCompactView: View {
    let componentId: String
    
    var body: some View {
        ReactNativeViewWrapper(componentId: componentId)
            .frame(height: 40)
    }
}

struct DynamicMinimalView: View {
    let componentId: String
    
    var body: some View {
        ReactNativeViewWrapper(componentId: componentId)
            .frame(height: 40)
    }
}

@available(iOS 16.2, *)
struct DynamicWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DynamicWidgetExtensionAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                DynamicHeaderView(
                    componentId: context.state.headerComponentId
                )
                DynamicBodyView(
                    componentId: context.state.bodyComponentId
                )
                DynamicFooterView(
                    componentId: context.state.footerComponentId
                )
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here
                DynamicIslandExpandedRegion(.leading, priority: 1, content: {
                    DynamicHeaderView(
                        componentId: context.state.headerComponentId
                    )
                })
                DynamicIslandExpandedRegion(.trailing, priority: 1, content: {
                    DynamicFooterView(
                        componentId: context.state.footerComponentId
                    )
                })
                DynamicIslandExpandedRegion(.center, priority: 1, content: {
                    DynamicBodyView(
                        componentId: context.state.bodyComponentId
                    )
                })
            } compactLeading: {
                // Compact leading UI
                DynamicCompactView(
                    componentId: context.state.compactLeadingComponentId
                )
            } compactTrailing: {
                // Compact trailing UI
                DynamicCompactView(
                    componentId: context.state.compactTrailingComponentId
                )
            } minimal: {
                // Minimal UI
                DynamicMinimalView(
                    componentId: context.state.bodyComponentId
                )
            }
        }
    }
}
