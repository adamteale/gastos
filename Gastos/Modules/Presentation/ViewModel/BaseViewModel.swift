//
//  BaseViewModel.swift
//  Gastos
//
//  Created by Adam Teale on 03-12-22.
//

import Foundation
import Combine

class BaseViewModel: ObservableObject {

    @Published var isLoading: ViewLoadingState = .notLoading

    private(set) var errorSubject = PassthroughSubject<UIErrorArgs, Never>()

    func onError(args: UIErrorArgs) {
        errorSubject.send(args)
    }

}
