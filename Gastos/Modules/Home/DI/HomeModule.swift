//
//  HomeModule.swift
//  Gastos
//
//  Created by Adam Teale on 03-12-22.
//

import Foundation

struct NoArgs {

}

final class HomeModule {

    private let container: DIContainer

    init(_ container: DIContainer) {
        self.container = container
    }

    func inject() {

        //MARK: Data layer

        container.register(type: PersistenceController.self) { resolver  in
            PersistenceController.shared
        }

        //MARK: Presentation layer

        container.register(type: HomeViewModel.self) { resolver in
            HomeViewModel(
                args: HomeViewModelArgs(
                    managedObjectContext: resolver.resolve(
                        type: PersistenceController.self
                    )!.container.viewContext
                )
            )
        }

        container.register(type: HomeView.self) { (resolver, args: HomeViewArgs) in
            HomeView(args: args)
        }

    }
}
