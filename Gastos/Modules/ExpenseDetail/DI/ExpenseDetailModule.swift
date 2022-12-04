//
//  ExpenseDetailModule.swift
//  Gastos
//
//  Created by Adam Teale on 03-12-22.
//

import Foundation

final class ExpenseDetailModule {

    private let container: DIContainer

    init(_ container: DIContainer) {
        self.container = container
    }

    func inject() {

        //MARK: Presentation layer

        container.register(type: ExpenseDetailViewModel.self) { (resolver, args: ExpenseDetailViewModelArgs) in
            ExpenseDetailViewModel(args: args)
        }

        container.register(type: ExpenseDetailView.self) { (resolver, args: ExpenseDetailViewArgs) in
            ExpenseDetailView(args: args)
        }

    }
}
