//
//  ReactNativeViewWrapper.swift
//  IslandExample
//
//  Created by Tristan Heilman on 6/19/25.
//
import SwiftUI
import Foundation

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
        // Read pre-rendered content from App Group storage
        let userDefaults = UserDefaults(suiteName: "group.island.example")
        let imageData = userDefaults?.data(forKey: "rendered_\(componentId)")
        
        if let imageData = imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .onAppear {
                    print("✅ Displaying pre-rendered image for component: \(componentId)")
                }
        } else {
            // Enhanced fallback with debugging info
            VStack {
                Text("Component: \(componentId)")
                    .font(.caption)
                Text("No image data found")
                    .font(.caption2)
                    .foregroundColor(.red)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .onAppear {
                print("❌ No pre-rendered image found for component: \(componentId)")
                print("Available keys in UserDefaults:")
                if let keys = userDefaults?.dictionaryRepresentation().keys {
                    for key in keys where key.hasPrefix("rendered_") {
                        print("  - \(key)")
                    }
                }
            }
        }
    }
}
