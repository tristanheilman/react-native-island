import SwiftUI
import Foundation

// Canonical snapshot view for react-native-island.
//
// Copy this file into your Widget Extension target alongside
// DynamicWidgetExtensionLiveActivity.swift. It reads a pre-rendered PNG that the
// main app wrote to the shared App Group and displays it. The componentId is the
// id you registered with `registerComponent` and passed in the activity data.
//
// IMPORTANT: replace APP_GROUP below with the App Group you pass to
// `setAppGroup(...)` from JavaScript. Both the app and this extension must have
// the same App Group capability enabled.

private let APP_GROUP = "group.your.app.island"

public struct ReactNativeViewWrapper: View {
    let componentId: String

    public init(componentId: String) {
        self.componentId = componentId
    }

    public var body: some View {
        PreRenderedComponentView(componentId: componentId)
    }
}

private struct PreRenderedComponentView: View {
    let componentId: String

    var body: some View {
        let userDefaults = UserDefaults(suiteName: APP_GROUP)
        let imageData = userDefaults?.data(forKey: "rendered_\(componentId)")

        if let imageData = imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            // Fallback shown when no snapshot is available yet.
            VStack {
                Text("Component: \(componentId)")
                    .font(.caption)
                Text("No image data found")
                    .font(.caption2)
                    .foregroundColor(.red)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
        }
    }
}
