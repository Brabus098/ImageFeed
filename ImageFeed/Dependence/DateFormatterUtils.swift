//  DateFormatterUtils.swift

import UIKit

enum DateFormatterUtils{
    
    static var ISOFormat: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        return formatter
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter}()
}

