import Foundation

struct Comment: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let content: String
    let date: Date?
    
    init(name: String, content: String, date: Date? = Date()) {
       self.name = name
       self.content = content
       self.date = date
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        lhs.id == rhs.id
    }
}
