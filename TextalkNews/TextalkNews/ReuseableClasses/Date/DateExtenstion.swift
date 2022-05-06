//
//  DateExtenstion.swift
//  TextalkNews
//
//  Created by gwl on 05/05/22.
//

import Foundation
enum AppDateFormats: String {
    case dMMMMyyyy = "d MMMM yyyy"
    case dMMMyyyy = "d MMM yyyy"
    case dMMMCommayyyy = "d MMM, yyyy"
    case yyyyMMdd          = "yyyy-MM-dd"
    case yyyy          = "yyyy"
    case yyyyMMddHHmm      = "yyyy-MM-dd HH:mm"
    case yyyyMMddHHmmss    = "yyyy-MM-dd HH:mm:ss"
    case yyyyMMddhhmma     =  "yyyy-MM-dd hh:mm a"
    case yyyyMMddTHHmmss   =  "yyyy-MM-dd'T'HH:mm:ss"
    case yyyyMMddTHHmmssZ  = "yyyy-MM-dd'T'HH:mm:ssZ"
    case yyyyMMddTHHmmssZ2 = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    case yyyyMMddTHHmmssSSSZZZZZ = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    case yyyyMMddTHHmmssZZZZZ = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    case dateTimeWithOffset = "yyyy-MM-dd'T'HH:mm:ssZZZ"
    case serverDateyyyyMMddTHHmmssSSSZ = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    case mmmdyyyyEEEE = "MMM d yyyy EEEE"
}

extension DateFormatter {
    func POSIX() -> DateFormatter {
    let localPos9 = Locale.current.identifier + "_POSIX"
    self.locale = Locale(identifier: localPos9)
        return self
    }
}
extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
    static func dates(from fromDate: Date, to toDate: Date) -> [Date] {
        var dates: [Date] = []
        var date = fromDate

        while date <= toDate {
            dates.append(date)
            guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
            date = newDate
        }
        return dates
    }
    func addDays(days: Int) -> Date {
        let newDate = Calendar.current.date(byAdding: .day, value: days, to: self)
        return newDate!
    }
    func isBetween(date date1: Date, andDate date2: Date) -> Bool {
        let dt1 = Calendar.current.startOfDay(for: date1)
        let dt2 = Calendar.current.startOfDay(for: date2)
        let selfDate = Calendar.current.startOfDay(for: self)
        return dt1.compare(selfDate).rawValue * selfDate.compare(dt2).rawValue >= 0
    }
    func isInDayOf(date: Date) -> Bool {
        return Calendar.current.isDate(date, inSameDayAs: self)
    }
    func setHourMinSecFromDate(fromDate: Date) -> Date {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: fromDate)
        let minutes = calendar.component(.minute, from: fromDate)
        let newDate = self.setDate(hour: hour, minute: minutes)
        return newDate
    }
    func compareDateWithoutTime(date: Date) -> Bool {
        let order = Calendar.current.compare(date, to: self, toGranularity: .day)
        switch order {
        case .orderedSame:
            return true
        default:
            return false
        }
    }
    func isBeforeDateWithoutTime(date: Date) -> Bool {
        let order = Calendar.current.compare(date, to: self, toGranularity: .day)
        switch order {
        case .orderedDescending:
            return true
        default:
            return false
        }
    }
    func isAfterDateWithoutTime(date: Date) -> Bool {
        let order = Calendar.current.compare(date, to: self, toGranularity: .day)
        switch order {
        case .orderedAscending:
            return true
        default:
            return false
        }
    }
    func setDateToMidnightTime() -> Date {
        let date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
        return date
    }
    func setDate(hour: Int, minute: Int) -> Date {
        let date = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: self)!
        return date
    }
    func minus(minutes: Int) -> Date {
        let minutes: TimeInterval = TimeInterval(minutes * 60)
        return self - minutes
    }
    func add(minutes: Int) -> Date {
        let minutes: TimeInterval = TimeInterval(minutes * 60)
        return self + minutes
    }
    func getDurationInMinute() -> Int {
        let component = Calendar.current.dateComponents([.hour, .minute, .second], from: self.toGlobalTime())
        var minutes = 0
        if let hour = component.hour {
            minutes = hour * 60
        }
        if let min = component.minute {
            minutes += min
        }
        return minutes
    }
    func getLoggedDateString() -> String {
        let currentDateStr = self.currentDateString(formate: AppDateFormats.yyyyMMdd.rawValue)!
        return currentDateStr
    }
    func getDateStringForFetchLogSleep() -> String {
        var currentDateStr = self.currentDateString(formate: AppDateFormats.yyyyMMdd.rawValue)!
        currentDateStr += " 06:00 PM"
        let dateFormate = DateFormatter().POSIX()
        dateFormate.dateFormat = AppDateFormats.yyyyMMddhhmma.rawValue
        let strCurrent = dateFormate.string(from: self)
        let pmDate: Date = dateFormate.date(from: currentDateStr)!
        let currentDate: Date = dateFormate.date(from: strCurrent)!
        if pmDate < currentDate {
            return self.currentDateString(formate: AppDateFormats.yyyyMMdd.rawValue)!
        } else {
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
            return yesterday!.currentDateString(formate: AppDateFormats.yyyyMMdd.rawValue)!
        }
    }
    func currentDateString(formate: String) -> String? {
        let dateFormate = DateFormatter().POSIX()
        dateFormate.dateFormat = formate
        return dateFormate.string(from: self)
    }
    func stringFromServerDate(serverString: String, serverDateFormate: String, dateInFormate: String) -> String? {
        let dateFormate = DateFormatter().POSIX()
        dateFormate.dateFormat = serverDateFormate
        let dateServer = dateFormate.date(from: serverString)
        dateFormate.dateFormat = dateInFormate
        return dateFormate.string(from: dateServer!)
    }
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    func timeStringWithAM_PM() -> String {
        return self.currentDateString(formate: "hh:mm a")!
    }
    func keepTimeAndChangeDateToToday() -> Date {
        let component = Calendar.current.dateComponents([.hour, .minute, .second], from: self)
        let date = Calendar.current.date(bySettingHour: component.hour!,
                                         minute: component.minute!, second: component.second!, of: Date())!
        return date
    }
    func setMidnightTime() -> Date {
        let date = Calendar.current.date(bySettingHour: 0,
                                         minute: 0, second: 0, of: self)!
        return date
    }
    func setEndOfDayTime() -> Date {
        let date = Calendar.current.date(bySettingHour: 23,
                                         minute: 59, second: 59, of: self)!
        return date
    }
    func setTimeToBack1HourAndMinute() -> Date {
        let component = Calendar.current.dateComponents([.hour, .minute, .second], from: self)
        var newHour: Int = component.hour ?? 0
        var newMinute: Int = component.minute ?? 0
        if newHour >= 1 {
            newHour -= 1
        } else {
            newMinute = 0
        }
        let date = Calendar.current.date(bySettingHour: newHour, minute: newMinute, second: 0, of: self)!
        return date
    }
    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }

    func getDateFromString(stringDate: String) -> Date {
        let dateFormate = DateFormatter().POSIX()
        dateFormate.dateFormat = "yyyy-MM-dd"
        return dateFormate.date(from: stringDate) ?? Date()
    }
    static func getDateTimeFromString(stringDate: String, formate: String) -> Date {
        let dateFormate = DateFormatter().POSIX()
        dateFormate.dateFormat = formate
        return dateFormate.date(from: stringDate) ?? Date()
    }
    func stringFromNSDate(_ date: Date, dateFormate: String) -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.full
        dateFormatter.dateFormat = dateFormate
        let formattedDate: String = dateFormatter.string(from: date)
        return formattedDate
    }
    func nsdateFromString(_ dateString: String, dateFormate: String) -> Date {
        var date: Date?
        if dateString != nil {
            //date formatter for the above string
            let dateFormatterWS: DateFormatter = DateFormatter()
            dateFormatterWS.timeZone = NSTimeZone(abbreviation: "UTC")! as TimeZone
            dateFormatterWS.dateFormat = dateFormate
            date = dateFormatterWS.date(from: dateString)
            //NSLog(@"Date %@",date);
            return date ?? Date()
        }
        let returnObject: Date?  = nil
        return returnObject ?? Date()
    }
}

extension Date {
    static func combineDateWithTime(date: Date, time: Date) -> Date {
        var calendar = NSCalendar.current
        var timeZoneObject = TimeZone.current
        if let utcTimeZone = TimeZone(abbreviation: "UTC") {
            timeZoneObject = utcTimeZone
        }
        calendar.timeZone = timeZoneObject
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        var mergedComponments = DateComponents()
        mergedComponments.year = dateComponents.year
        mergedComponments.month = dateComponents.month
        mergedComponments.day = dateComponents.day
        mergedComponments.hour = timeComponents.hour
        mergedComponments.minute = timeComponents.minute
        mergedComponments.second = timeComponents.second
        if let mergedDate = calendar.date(from: mergedComponments) {
            return mergedDate
        }
        return date
    }
    static func combineDateStringWithDate(dateString: String, dateObj: Date) -> String {
        var calendar = NSCalendar.current
        var timeZoneObject = TimeZone.current
        if let utcTimeZone = TimeZone(abbreviation: "UTC") {
            timeZoneObject = utcTimeZone
        }
        calendar.timeZone = timeZoneObject
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd"
        let newDateString = formater.string(from: dateObj)
        let value: NSMutableString = NSMutableString(string: dateString)
        let pattern = "([12]\\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\\d|3[01]))"
        let regex = try? NSRegularExpression(pattern: pattern)
        regex?.replaceMatches(in: value, options: .reportProgress,
                              range: NSRange(location: 0, length: value.length),
                              withTemplate: newDateString)
        return value as String
    }
    func convertDateStrFormat(oldFormat: AppDateFormats, newFormat: AppDateFormats, dateStr: String) -> String {
        let date = Date.getDateTimeFromString(stringDate: dateStr, formate: oldFormat.rawValue)
        let formattedStr = date.currentDateString(formate: newFormat.rawValue) ?? ""
        return formattedStr
    }
}
extension Date {
    func formated(withFormat format: String = "yyyy/MM/dd") -> Date? {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = format
        let dateString = formatter.string(from: self)
        return formatter.date(from: dateString)
    }

    func daysSince(_ anotherDate: Date) -> Int? {
        if let fromDate = dateFromComponents(self), let toDate = dateFromComponents(anotherDate) {
            let components = Calendar.current.dateComponents([.day], from: fromDate, to: toDate)
            return components.day
        }
        return nil
    }

    private func dateFromComponents(_ date: Date) -> Date? {
        let calender   = Calendar.current
        let components = calender.dateComponents([.year, .month, .day], from: date)
        return calender.date(from: components)
    }
}


extension Date {
    func offset(from: Date) -> (Calendar.Component, Int)? {
        let descendingOrderedComponents = [Calendar.Component.year, .month, .day, .hour, .minute]
        let dateComponents = Calendar.current.dateComponents(Set(descendingOrderedComponents), from: from, to: self)
        let arrayOfTuples = descendingOrderedComponents.map { ($0, dateComponents.value(for: $0)) }

        for (component, value) in arrayOfTuples {
            if let value = value, value > 0 {
                return (component, value)
            }
        }

        return nil
    }

}
