//
//  String+Extension.swift
//  19
//
//  Created by Yush Raj Kapoor on 11/18/23.
//

import Foundation


extension String {
    func toDate(format:String?="yyyy-MM-dd") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: self)
    }
}
