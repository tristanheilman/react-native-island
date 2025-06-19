import Foundation
import React

class ComponentRegistry {
    static let shared = ComponentRegistry()
    private var components: [String: String] = [:] // componentId -> componentName mapping
    
    func registerComponent(id: String, componentName: String) {
        components[id] = componentName
    }
    
    func getComponentName(id: String) -> String? {
        return components[id]
    }
    
    func getComponent(id: String) -> String? {
        return components[id]
    }
    
    func clearComponent(id: String) {
        components.removeValue(forKey: id)
    }
    
    func getAllComponents() -> [String: String] {
        return components
    }
}