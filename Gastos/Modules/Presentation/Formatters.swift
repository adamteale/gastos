//
//  Formatters.swift
//  Gastos
//
//  Created by Adam Teale on 25-11-22.
//

import Foundation

struct Formatters {

    static let currencyFormatter: Formatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "es_CL")
        numberFormatter.maximumFractionDigits = 0
        return numberFormatter
    }()

    static let currencyFormatterNoSymbol: Formatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.zeroSymbol = ""
        numberFormatter.locale = Locale(identifier: "es_CL")
        numberFormatter.maximumFractionDigits = 0
        return numberFormatter
    }()

    static let onlyDate: Formatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .full
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    static let onlyMonth: Formatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLL"
        return formatter
    }()

    static let onlyYear: Formatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
}
