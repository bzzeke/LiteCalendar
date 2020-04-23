import UIKit
import SnapKit

public final class LiteCalendar: UIView, DaySelectorDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    public struct Settings {
        public var daysInWeek: Int
        public var showDateLabel: Bool
        public var style: CalendarStyle
        public var maxDate: Date?
        public var minDate: Date?

        public init(daysInWeek: Int = 7, showDateLabel: Bool = false, style: CalendarStyle = CalendarStyle(), maxDate: Date? = nil, minDate: Date? = nil) {
            self.daysInWeek = daysInWeek
            self.showDateLabel = showDateLabel
            self.style = style
            self.maxDate = maxDate
            self.minDate = minDate
        }
    }

    private var constraintsCreated = false
    var settings = Settings()
    public let calendar: Calendar
    private var currentSizeClass = UIUserInterfaceSizeClass.compact {
        didSet {
            daySymbolsView.isHidden = currentSizeClass == .regular
            (pagingViewController.children as? [DaySelectorController])?.forEach{$0.transitionToHorizontalSizeClass(currentSizeClass)}

        }
    }
    public weak var delegate: CalendarChangeDate?

    public var selectedDate = Date() {
        didSet {
            swipeLabelView.selectedDate = selectedDate
        }
    }

    private var currentWeekdayIndex = -1

    private var daySymbolsViewHeight: CGFloat = 20
    private var pagingScrollViewHeight: CGFloat = 40
    private var swipeLabelViewHeight: CGFloat = 20

    private let daySymbolsView: DaySymbolsView
    private var pagingViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    private let swipeLabelView: SwipeLabelView


    public init(calendar: Calendar = Calendar.autoupdatingCurrent) {
        self.settings = Settings()
        self.calendar = calendar
        self.daySymbolsView = DaySymbolsView(calendar: calendar)
        self.swipeLabelView = SwipeLabelView(calendar: calendar)

        super.init(frame: .zero)
        configure()
    }

    public init(settings: Settings, calendar: Calendar = Calendar.autoupdatingCurrent) {
        self.settings = settings
        self.calendar = calendar
        self.daySymbolsView = DaySymbolsView(calendar: calendar)
        self.swipeLabelView = SwipeLabelView(calendar: calendar)

        super.init(frame: .zero)
        configure()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        currentSizeClass = traitCollection.horizontalSizeClass
        daySymbolsView.isHidden = currentSizeClass == .regular
        swipeLabelView.isHidden = !settings.showDateLabel
        swipeLabelView.selectedDate = selectedDate

        addSubview(daySymbolsView)
        addSubview(swipeLabelView)
        backgroundColor = settings.style.backgroundColor
        configurePagingViewController()
    }

    private func configurePagingViewController() {
        let vc = makeSelectorController(startDate: selectedDate.beginningOfWeek(with: calendar))
        vc.selectedDate = selectedDate
        currentWeekdayIndex = vc.selectedIndex
        pagingViewController.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
        pagingViewController.dataSource = self
        pagingViewController.delegate = self
        addSubview(pagingViewController.view!)
    }

    private func makeSelectorController(startDate: Date) -> DaySelectorController {
        let new = DaySelectorController()
        new.calendar = calendar
        new.transitionToHorizontalSizeClass(currentSizeClass)
        new.updateStyle(settings.style.daySelector)
        new.startDate = startDate
        new.delegate = self

        return new
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        guard constraintsCreated == false else {
            return
        }

        constraintsCreated = true

        daySymbolsView.snp.makeConstraints {(make) -> Void in
            make.top.leading.trailing.equalTo(self)
            make.height.equalTo(daySymbolsViewHeight)
        }

        swipeLabelView.snp.makeConstraints {(make) -> Void in
            make.top.equalTo(pagingViewController.view.snp.bottom).offset(10)
            make.leading.trailing.equalTo(self)
            make.height.equalTo(swipeLabelViewHeight)
        }

        pagingViewController.view?.snp.makeConstraints {(make) -> Void in
            make.top.equalTo(self.daySymbolsView.snp.bottom).offset(10)
            make.centerX.equalTo(self.daySymbolsView)
            make.leading.trailing.equalTo(self)
            make.height.equalTo(pagingScrollViewHeight)
        }
    }

    public func transitionToHorizontalSizeClass(_ sizeClass: UIUserInterfaceSizeClass) {
        currentSizeClass = sizeClass
    }

    // MARK: DaySelectorDelegate
    public func dateSelectorDidSelectDate(_ date: Date) {

        if canChange(to: date) {
            delegate?.change(to: date)
            move(to: date)
            selectedDate = date
        }
    }

    func canChange(to date: Date) -> Bool {
        if
            settings.minDate == nil || settings.minDate!.endOfDay <= date.endOfDay,
            settings.maxDate == nil || settings.maxDate!.endOfDay >= date.endOfDay {
            return true
        }

        return false
    }

    // MARK: DayViewStateUpdating
    func move(to newDate: Date) {

        let newDate = newDate.dateOnly(calendar: calendar)

        let centerView = pagingViewController.viewControllers![0] as! DaySelectorController
        let startDate = centerView.startDate.dateOnly(calendar: calendar)

        let daysFrom = newDate.days(from: startDate, calendar: calendar)
        let newStartDate = newDate.beginningOfWeek(with: calendar)

        let new = makeSelectorController(startDate: newStartDate)

        if daysFrom < 0 {
            currentWeekdayIndex = abs(settings.daysInWeek + daysFrom % settings.daysInWeek) % settings.daysInWeek
          new.selectedIndex = currentWeekdayIndex
          pagingViewController.setViewControllers([new], direction: .reverse, animated: true, completion: nil)
        } else if daysFrom > settings.daysInWeek - 1 {
          currentWeekdayIndex = daysFrom % settings.daysInWeek
          new.selectedIndex = currentWeekdayIndex
          pagingViewController.setViewControllers([new], direction: .forward, animated: true, completion: nil)
        } else {
          currentWeekdayIndex = daysFrom
          centerView.selectedDate = newDate
          centerView.selectedIndex = currentWeekdayIndex
        }
    }

    // MARK: UIPageViewControllerDataSource
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if
            let selector = viewController as? DaySelectorController,
            let previousDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selector.startDate),
            settings.minDate == nil || settings.minDate!.endOfDay < previousDate.endOfDay
        {
            return makeSelectorController(startDate: previousDate)
        }
        return nil
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if
            let selector = viewController as? DaySelectorController,
            let nextDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selector.startDate),
            settings.maxDate == nil || settings.maxDate!.endOfDay > nextDate.endOfDay
        {
            return makeSelectorController(startDate: nextDate)
        }
        return nil
    }

    // MARK: UIPageViewControllerDelegate
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else {
            return
        }

        if let selector = pageViewController.viewControllers?.first as? DaySelectorController {
            selector.selectedIndex = currentWeekdayIndex
            if let selectedDate = selector.selectedDate {
            // FIXME: zeke
                dateSelectorDidSelectDate(selectedDate)
            }
        }
        // Deselect all the views but the currently visible one
        (previousViewControllers as? [DaySelectorController])?.forEach{$0.selectedIndex = -1}
    }

    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        (pendingViewControllers as? [DaySelectorController])?.forEach{$0.updateStyle(settings.style.daySelector)}
    }
}
