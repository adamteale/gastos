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
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }()

    static let onlyDate: Formatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .full
        formatter.timeZone = TimeZone.current
        return formatter
    }()
}
