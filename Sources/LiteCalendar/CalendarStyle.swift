import Foundation
import UIKit

public struct CalendarStyle {
    public var daySymbols = DaySymbols()
    public var daySelector = DaySelector()
    public var swipeLabel = SwipeLabel()
    public var backgroundColor = UIColor(white: 247/255, alpha: 1)
    public init() {}

    public struct DaySelector {
        public var activeTextColor = UIColor.white
        public var selectedBackgroundColor = UIColor.black

        public var weekendTextColor = UIColor.gray
        public var inactiveTextColor = UIColor.black
        public var inactiveBackgroundColor = UIColor.clear

        public var todayInactiveTextColor = UIColor.red
        public var todayActiveTextColor = UIColor.white
        public var todayActiveBackgroundColor = UIColor.red

        public var font = UIFont.systemFont(ofSize: 18)
        public var todayFont = UIFont.boldSystemFont(ofSize: 18)

        public init() {}
    }

    public struct DaySymbols {
        public var weekendColor = UIColor.lightGray
        public var weekDayColor = UIColor.black
        public var font = UIFont.systemFont(ofSize: 10)
        public init() {}
    }

    public struct SwipeLabel {
        public var textColor = UIColor.black
        public var font = UIFont.systemFont(ofSize: 15)
        public init() {}
    }

}
