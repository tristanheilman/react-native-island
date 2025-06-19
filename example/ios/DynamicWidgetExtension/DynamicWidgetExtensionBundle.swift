//
//  DynamicWidgetExtensionBundle.swift
//  DynamicWidgetExtension
//
//  Created by Tristan Heilman on 6/18/25.
//

import WidgetKit
import SwiftUI

@main
struct DynamicWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        DynamicWidgetExtension()
        DynamicWidgetExtensionLiveActivity()
    }
}
