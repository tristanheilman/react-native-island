import ActivityKit
import WidgetKit
import SwiftUI

struct DynamicWidgetExtensionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var headerComponentId: String
        var headerProps: String
        var bodyComponentId: String
        var bodyProps: String
        var footerComponentId: String
        var footerProps: String
        
        init(headerComponentId: String = "", headerProps: String = "",
             bodyComponentId: String = "", bodyProps: String = "",
             footerComponentId: String = "", footerProps: String = "") {
            self.headerComponentId = headerComponentId
            self.headerProps = headerProps
            self.bodyComponentId = bodyComponentId
            self.bodyProps = bodyProps
            self.footerComponentId = footerComponentId
            self.footerProps = footerProps
        }
    }
}

struct DynamicHeaderView: View {
    let componentId: String
    let props: String
    
    var body: some View {
        //Text("Header")
        ReactNativeViewWrapper(componentId: componentId, props: props)
            .frame(height: 60)
    }
}

struct DynamicBodyView: View {
    let componentId: String
    let props: String

    var body: some View {
        //Text("Body")
        ReactNativeViewWrapper(componentId: componentId, props: props)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct DynamicFooterView: View {
    let componentId: String
    let props: String
    
    var body: some View {
        Text("Footer")
        ReactNativeViewWrapper(componentId: componentId, props: props)
            .frame(height: 40)
    }
}

struct DynamicCompactView: View {
    let componentId: String
    let props: String
    
    var body: some View {
        Text("Compact")
        // ReactNativeViewWrapper(componentId: componentId, props: props)
        //     .frame(width: 30, height: 30)
    }
}

struct DynamicMinimalView: View {
    let componentId: String
    let props: String
    
    var body: some View {
        Text("Minimal")
        // ReactNativeViewWrapper(componentId: componentId, props: props)
        //     .frame(width: 20, height: 20)
    }
}

@available(iOS 16.2, *)
struct DynamicWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DynamicWidgetExtensionAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                DynamicHeaderView(
                    componentId: context.state.headerComponentId,
                    props: context.state.headerProps
                )
                DynamicBodyView(
                    componentId: context.state.bodyComponentId,
                    props: context.state.bodyProps
                )
                DynamicFooterView(
                    componentId: context.state.footerComponentId,
                    props: context.state.footerProps
                )
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here
                DynamicIslandExpandedRegion(.leading, priority: 1, content: {
                    DynamicHeaderView(
                        componentId: context.state.headerComponentId,
                        props: context.state.headerProps
                    )
                })
                DynamicIslandExpandedRegion(.trailing, priority: 1, content: {
                    DynamicFooterView(
                        componentId: context.state.footerComponentId,
                        props: context.state.footerProps
                    )
                })
                DynamicIslandExpandedRegion(.center, priority: 1, content: {
                    DynamicBodyView(
                        componentId: context.state.bodyComponentId,
                        props: context.state.bodyProps
                    )
                })
            } compactLeading: {
                // Compact leading UI
                DynamicCompactView(
                    componentId: context.state.headerComponentId,
                    props: context.state.headerProps
                )
            } compactTrailing: {
                // Compact trailing UI
                DynamicCompactView(
                    componentId: context.state.footerComponentId,
                    props: context.state.footerProps
                )
            } minimal: {
                // Minimal UI
                DynamicMinimalView(
                    componentId: context.state.bodyComponentId,
                    props: context.state.bodyProps
                )
            }
        }
    }
}
