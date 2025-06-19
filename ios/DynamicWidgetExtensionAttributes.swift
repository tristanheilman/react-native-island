import ActivityKit

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
