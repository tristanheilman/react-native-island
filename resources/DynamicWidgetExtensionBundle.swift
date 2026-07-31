import WidgetKit
import SwiftUI

@available(iOS 16.2, *)
@main
struct DynamicWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        DynamicWidgetExtensionLiveActivity()
    }
}
