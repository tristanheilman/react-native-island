import WidgetKit
import SwiftUI

@available(iOS 16.2, *)
@main
struct DynamicWidgetBundle: WidgetBundle {
    var body: some Widget {
        DynamicWidgetExtension()
        DynamicWidgetExtensionLiveActivity()
    }
}