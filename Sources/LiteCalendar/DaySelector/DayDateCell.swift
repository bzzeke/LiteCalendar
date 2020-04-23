import UIKit
import SnapKit

public final class DayDateCell: UIView, DaySelectorItemProtocol {

    private let dateLabel = DateLabel()
    private let dayLabel = UILabel()
    private var constraintsSet = false

    private var regularSizeClassFontSize: CGFloat = 16

    public var date = Date() {
        didSet {
            dateLabel.date = date
            updateState()
        }
    }

    public var calendar = Calendar.autoupdatingCurrent {
        didSet {
            dateLabel.calendar = calendar
            updateState()
        }
    }

    public var selected: Bool {
        get {
            return dateLabel.selected
        }
        set(value) {
            dateLabel.selected = value
        }
    }

    var style = CalendarStyle.DaySelector()

    override public var intrinsicContentSize: CGSize {
        return CGSize(width: 75, height: 35)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    private func configure() {
        clipsToBounds = true
        addSubview(dayLabel)
        addSubview(dateLabel)
    }

    public func updateStyle(_ newStyle: CalendarStyle.DaySelector) {
        style = newStyle
        dateLabel.updateStyle(newStyle)
        updateState()
    }

    private func updateState() {
        let isWeekend = isAWeekend(date: date)
        dayLabel.font = UIFont.systemFont(ofSize: regularSizeClassFontSize)
        dayLabel.textColor = isWeekend ? style.weekendTextColor : style.inactiveTextColor
        dateLabel.updateState()
        updateDayLabel()
        setNeedsLayout()
    }

    private func updateDayLabel() {
        let daySymbols = calendar.shortWeekdaySymbols
        let weekendMask = [true] + [Bool](repeating: false, count: 5) + [true]
        var weekDays = Array(zip(daySymbols, weekendMask))
        weekDays.shift(calendar.firstWeekday - 1)
        let weekDay = calendar.component(.weekday, from: date)
        dayLabel.text = daySymbols[weekDay - 1]
    }

    private func isAWeekend(date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        if weekday == 7 || weekday == 1 {
            return true
        }
        return false
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        guard constraintsSet == false else {
            return
        }

        constraintsSet = true
        dateLabel.snp.makeConstraints {(make) -> Void in
            make.trailing.equalTo(self).offset(-5)
            make.centerY.equalTo(self)
            make.width.height.equalTo(30)
        }

        dayLabel.snp.makeConstraints {(make) -> Void in
            make.centerY.equalTo(self)
            make.top.leading.bottom.equalTo(self)
            make.trailing.equalTo(dateLabel.snp.leading).offset(-5)
        }
    }

    override public func tintColorDidChange() {
        updateState()
    }
}
