
import Foundation

extension Date {
    
    func getDateStringVariation(from datetime: String) -> String {
        let calendar = Calendar.current
        let recdDate = convertUTCToLocalDate(dateStr: datetime, sourceFormate: "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ", destinationFormate: "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ")
        
        if calendar.isDateInToday(recdDate) {
            return convertUTCToLocalDate(dateStr: datetime, sourceFormate: "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ", destinationFormate: "HH:mm").getDateStringWithFormate("HH:mm", timezone: TimeZone.current.abbreviation()!)
        } else if calendar.isDateInYesterday(recdDate) {
            return "Yesterday"
        } else {
            let fromDate = self.addDays(-7)
            let range = fromDate...self
            if range.contains(recdDate) {
                return convertUTCToLocalDate(dateStr: datetime, sourceFormate: "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ", destinationFormate: "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ").getDateStringWithFormate("EEEE", timezone: TimeZone.current.abbreviation()!)
            } else {
                return convertUTCToLocalDate(dateStr: datetime, sourceFormate: "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ", destinationFormate: "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ").getDateStringWithFormate("MMM dd,yyyy", timezone: TimeZone.current.abbreviation()!)
            }
        }
    }
    
    func getDateStringWithFormate(_ formate: String, timezone: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = formate
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }
    
    func getDateStringWithLanguageFormate(_ formate: String, timezone: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = formate
        //let langg = LangaugeSelected(rawValue: Utility.shared.selectedLocalizeLanguage)
        //formatter.locale = Locale(identifier: langg?.rawValue ?? "ga")
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }

    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970)
    }
    
    func isGreaterThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    func addDays(_ daysToAdd: Int) -> Date {
        let secondsInDays: TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: Date = self.addingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(_ hoursToAdd: Int) -> Date {
        let secondsInHours: TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: Date = self.addingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
    
    func addMinutes(minutes: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .minute, value: minutes, to: self)!
    }
}
