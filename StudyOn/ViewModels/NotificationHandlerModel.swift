import SwiftUI

class NotificationHandlerModel: ObservableObject {
    static let shared = NotificationHandlerModel()
    
    @Published var doNavigate: Bool = false
    var studyLocation: StudyLocation? = nil
    var allowDynamicDataSubmit: Bool = true
}
