import Foundation
import React
import UIKit

class ComponentRegistry {
    static let shared = ComponentRegistry()
    private var components: [String: String] = [:] // componentId -> componentName mapping
    private var viewReferences: [String: WeakViewReference] = [:] // componentId -> view reference
    
    func registerComponent(id: String, componentName: String) {
        components[id] = componentName
    }
    
    func getComponentName(id: String) -> String? {
        return components[id]
    }
    
    func getComponent(id: String) -> String? {
        return components[id]
    }
    
    // Store a reference to a rendered component view
    func storeViewReference(id: String, view: UIView) {
        viewReferences[id] = WeakViewReference(view: view)
    }
    
    // Get the stored view reference
    func getViewReference(id: String) -> UIView? {
        return viewReferences[id]?.view
    }
    
    func clearComponent(id: String) {
        components.removeValue(forKey: id)
        viewReferences.removeValue(forKey: id)
    }
    
    func getAllComponents() -> [String: String] {
        return components
    }
}

// Weak reference to avoid retain cycles
class WeakViewReference {
    weak var view: UIView?
    
    init(view: UIView) {
        self.view = view
    }
}