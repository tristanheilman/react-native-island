import SwiftUI
import Foundation

public struct ReactNativeViewWrapper: View {
    let componentId: String
    let props: String
    
    public init(componentId: String, props: String) {
        self.componentId = componentId
        self.props = props
    }
    
    public var body: some View {
        // This will display pre-rendered content from the main app
        PreRenderedComponentView(componentId: componentId, props: props)
    }
}

private struct PreRenderedComponentView: View {
    let componentId: String
    let props: String
    
    var body: some View {
        // Read pre-rendered content from App Group storage
        let userDefaults = UserDefaults(suiteName: "group.your.app.group")
        let imageData = userDefaults?.data(forKey: "rendered_\(componentId)")
        
        if let imageData = imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            // Fallback if no pre-rendered content is available
            Text("Component: \(componentId)")
                .padding()
                .background(Color.gray.opacity(0.1))
        }
    }
}

// import SwiftUI
// import React

// struct ReactNativeViewWrapper: UIViewRepresentable {
//     let componentId: String
//     let props: String
    
//     func makeUIView(context: Context) -> UIView {
//         let view = UIView()
//         view.backgroundColor = .clear
        
//         // Get the component name from registry
//         if let componentName = ComponentRegistry.shared.getComponentName(id: componentId) {
//             print("Rendering component: \(componentName) with props: \(props)")
            
//             // Create React Native root view with the component
//             if let bridge = RCTBridge(delegate: nil, launchOptions: nil) {
//                 let rootView = RCTRootView(
//                     bridge: bridge,
//                     moduleName: "DynamicLiveActivity",
//                     initialProperties: [
//                         "componentId": componentId,
//                         "componentName": componentName,
//                         "props": props
//                     ]
//                 )
                
//                 rootView.frame = view.bounds
//                 rootView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//                 view.addSubview(rootView)
//             }
//         } else {
//             print("Warning: Component not found for ID: \(componentId)")
//             // Add a fallback view
//             let label = UILabel()
//             label.text = "Component not found: \(componentId)"
//             label.textColor = .red
//             label.textAlignment = .center
//             label.frame = view.bounds
//             label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//             view.addSubview(label)
//         }
        
//         return view
//     }
    
//     func updateUIView(_ uiView: UIView, context: Context) {
//         // Update the component if needed
//         if let rootView = uiView.subviews.first as? RCTRootView {
//             rootView.appProperties = [
//                 "componentId": componentId,
//                 "componentName": ComponentRegistry.shared.getComponentName(id: componentId) ?? "",
//                 "props": props
//             ]
//         }
//     }
// }