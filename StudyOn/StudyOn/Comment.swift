import Foundation

struct Comment: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let content: String
    let date: Date?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        lhs.id == rhs.id
    }
}
