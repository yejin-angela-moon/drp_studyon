import Foundation

struct OpeningHours {
    var opening: String
    var closing: String
    
}

extension Dictionary where Key == String, Value == OpeningHours {
    func isOpenNow() -> Bool {
        let now = Date()
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let weekday = calendar.dateComponents([.weekday], from: now).weekday else {
            return false
        }
        
        let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let today = daysOfWeek[weekday - 1]
        
        guard let hours = self[today] else {
            return false
        }
        
        if hours.opening == "Closed" || hours.closing == "Closed" {
            return false
        }
        
        let currentTimeComponents = calendar.dateComponents([.hour, .minute], from: now)
               guard let openingTime = formatter.date(from: hours.opening),
                     let closingTime = formatter.date(from: hours.closing),
                     let currentTime = calendar.date(from: currentTimeComponents) else {
                   return false
               }
        return currentTime >= openingTime && currentTime <= closingTime

    }
}
