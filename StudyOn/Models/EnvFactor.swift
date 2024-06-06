import Foundation

struct EnvFactor: Identifiable, Hashable {
    let id = UUID()
    let dynamicData: [String: Double]
    let staticData: [String: Double]
    let atmosphere: [String]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: EnvFactor, rhs: EnvFactor) -> Bool {
        lhs.id == rhs.id
    }
}
