//
//  Date+Extension.swift
//  19
//
//  Created by Yush Raj Kapoor on 11/18/23.
//

import Foundation


extension Date {
    func toString(format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
