//
//  CalendarViewController.swift
//  19
//
//  Created by Yush Raj Kapoor on 11/21/23.
//

import Foundation
import UIKit

class CalendarViewController: UIViewController {
    private let calendarView = UICalendarView()
    var delegate: Levels!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let startTime = UserDefaults.standard.double(forKey: "startDate")
        let startDate = Date(timeIntervalSince1970: startTime)
        let endTime = UserDefaults.standard.double(forKey: "endDate")
        let endDate = min(Date(timeIntervalSince1970: endTime), Date.now)
        
        let gregorianCalendar = Calendar(identifier: .gregorian)
        calendarView.calendar = gregorianCalendar
        calendarView.availableDateRange = DateInterval(start: startDate, end: endDate)
        
        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = selection
        calendarView.delegate = self
        
        // Add calendar view
        view.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            calendarView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
        
    }
}

extension CalendarViewController: UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        if let dt = dateComponents?.date {
            print(dt)
            targetDate = dt
            downloadLevels(forDate: targetDate)
        }
        dismiss(animated: true) {
            self.delegate.updateButtonStates()
        }
        
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?) -> Bool {
        return true
    }
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        let dt = dateComponents.date
        if let setsCompleted = UserDefaults.standard.dictionary(forKey: "setsCompleted") as? [String: Bool], let fDate = dt?.toString(format: "yyyyMMdd"), setsCompleted.keys.contains(fDate) {
            return setsCompleted[fDate]! ? UICalendarView.Decoration.default(color: .systemGreen, size: .small) : nil
        }
        
        return nil
    }
    
}
