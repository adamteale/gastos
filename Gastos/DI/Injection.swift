//
//  Injection.swift
//  Gastos
//
//  Created by Adam Teale on 03-12-22.
//


import SwiftUI

final class Injection {

    static let shared = Injection()

    private let container = DIContainer.shared

    private init() {
        injectDependencies()
    }

    private func injectDependencies() {
        HomeModule(container).inject()
        ExpenseDetailModule(container).inject()
    }

}
