import ActivityKit

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
