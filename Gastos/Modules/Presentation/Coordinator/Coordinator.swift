//
//  Coordinator.swift
//  Gastos
//
//  Created by Adam Teale on 03-12-22.
//

import SwiftUI

protocol Coordinator {
    associatedtype V: View
    func start() -> V
}

//class Coordinator: ObservableObject {
//
//    let navigationController: UINavigationController
//    let container: DIContainer
//
//    init(
//        container: DIContainer,
//        navigationController: UINavigationController = .init()
//    ) {
//        self.container = container
//        self.navigationController = navigationController
//    }
//
//    func pushViewController<V: UIViewController>(
//        viewController: UIViewController,
//        newViewControllerType: V.Type
//    ) {
//        var newViewController: V!
//        navigationController.pushViewController(newViewController, animated: true)
//    }
//
//    func popViewController(viewController: UIViewController, animated: Bool) {
//        viewController.navigationController?.popViewController(animated: animated)
//    }
//
//}
