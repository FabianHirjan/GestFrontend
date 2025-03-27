// Utils/DateFormatterHelper.swift
import Foundation

enum DateFormat {
    static let server = "yyyy-MM-dd HH:mm:ss.SSSSSS"
    static let display = "yyyy-MM-dd"
    static let iso8601 = "yyyy-MM-dd'T'HH:mm:ssZ"
}

class DateFormatterHelper {
    static func formatDate(_ dateString: String?, fromFormat: String = DateFormat.server, toFormat: String = DateFormat.display) -> String {
        guard let dateString = dateString else { return "N/A" }
        let inFormatter = DateFormatter()
        inFormatter.dateFormat = fromFormat
        guard let date = inFormatter.date(from: dateString) else { return "N/A" }
        let outFormatter = DateFormatter()
        outFormatter.dateFormat = toFormat
        return outFormatter.string(from: date)
    }
    
    static func dateToString(_ date: Date, format: String = DateFormat.display) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
