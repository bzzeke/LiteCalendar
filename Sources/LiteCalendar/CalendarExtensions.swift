//
//  CalendarState.swift
//  vidoo2
//
//  Created by Ilya Shalnev on 22.04.2020.
//  Copyright © 2020 Ilya Shalnev. All rights reserved.
//

import Foundation

public protocol DayViewStateUpdating: AnyObject {
    func move(from oldDate: Date, to newDate: Date)
}

public protocol CalendarChangeDate: AnyObject {
    func change(to newDate: Date)
}

extension Array {
    mutating func shift(_ amount: Int) {
        var amount = amount
        guard -count...count ~= amount else { return }
        if amount < 0 {
            amount += count
        }
        self = Array(self[amount ..< count] + self[0 ..< amount])
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    func isLater(than date: Date) -> Bool {
        return self.compare(date) == .orderedDescending
    }

    func dateOnly(calendar: Calendar) -> Date {
        let yearComponent = calendar.component(.year, from: self)
        let monthComponent = calendar.component(.month, from: self)
        let dayComponent = calendar.component(.day, from: self)
        let zone = calendar.timeZone

        let newComponents = DateComponents(timeZone: zone,
                                         year: yearComponent,
                                         month: monthComponent,
                                         day: dayComponent)
        let returnValue = calendar.date(from: newComponents)
        return returnValue!
    }

    func days(from date: Date, calendar: Calendar?) -> Int {
        var calendarCopy = calendar
        if (calendar == nil) {
            calendarCopy = Calendar.autoupdatingCurrent
        }

        let earliest = earlierDate(date)
        let latest = (earliest == self) ? date : self
        let multiplier = (earliest == self) ? -1 : 1
        let components = calendarCopy!.dateComponents([.day], from: earliest, to: latest)
        return multiplier*components.day!
    }

    func earlierDate(_ date:Date) -> Date{
        return (self.timeIntervalSince1970 <= date.timeIntervalSince1970) ? self : date
    }

    func beginningOfWeek(with calendar: Calendar) -> Date {

        let weekOfYear = calendar.component(.weekOfYear, from: self)
        let yearForWeekOfYear = calendar.component(.yearForWeekOfYear, from: self)

        return calendar.date(from: DateComponents(calendar: calendar,
                                                weekday: calendar.firstWeekday,
                                                weekOfYear: weekOfYear,
                                                yearForWeekOfYear: yearForWeekOfYear))!
    }

    func endOfWeek(with calendar: Calendar) -> Date {

        let weekEndDay = calendar.firstWeekday + 6
        let weekOfYear = calendar.component(.weekOfYear, from: self)
        let yearForWeekOfYear = calendar.component(.yearForWeekOfYear, from: self)

        return calendar.date(from: DateComponents(calendar: calendar,
                                                weekday: weekEndDay,
                                                weekOfYear: weekOfYear,
                                                yearForWeekOfYear: yearForWeekOfYear))!
    }

}


