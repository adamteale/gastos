//
//  HomeCoordinator.swift
//  Gastos
//
//  Created by Adam Teale on 03-12-22.
//

import Foundation
import SwiftUI

final class HomeCoordinator: Coordinator {

    enum Scene: Hashable {
        case expenseDetail(Expense?)
        case categoryDetail(Category?)
        case tagDetail(Tag?)
        case accountDetail(Account?)
    }

    private let container: DIContainer

    init(
        container: DIContainer
    ) {
        self.container = container
    }

    func start() -> some View {

        let homeViewModel = container.resolve(
            type: HomeViewModel.self
        )!

        let homeViewArgs = HomeViewArgs(viewModel: homeViewModel)

        let homeView = container.resolve(
            type: HomeView.self,
            args: homeViewArgs
        )!
        return homeView
    }

    func goToScene(_ scene: Scene, view: some View) {
        //        switch scene {
        //        case .expenseDetail(let args):

        ////            let viewWithCoordinator = view.environmentObject(self)
        ////            let viewController = UIHostingController(rootView: viewWithCoordinator)
        //            let viewController = UIHostingController(rootView: view)
        //
        //            let destinationView = container.resolve(type: ExpenseDetailView.self, args: args)
        //            let destinationViewController = UIHostingController(rootView: destinationView)
        //            navigationController.pushViewController(destinationViewController, animated: true)
        //
        //            //            pushViewController(viewController: viewController, newViewControllerType: destinationViewController)
    }

}
