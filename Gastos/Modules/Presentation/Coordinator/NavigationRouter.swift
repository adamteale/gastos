//
//  NavigationRouter.swift
//  Gastos
//
//  Created by Adam Teale on 03-12-22.
//

import SwiftUI

protocol NavigationRouter {

    associatedtype V: View

//    var transition: NavigationTransitionStyle { get }


    @ViewBuilder
    func view() -> V
}
