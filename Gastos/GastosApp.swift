//
//  GastosApp.swift
//  Gastos
//
//  Created by Adam Teale on 25-11-22.
//

import SwiftUI

@main
struct GastosApp: App {

    private let injection = Injection.shared

    private let coordinator = HomeCoordinator(container: DIContainer.shared)

    var body: some Scene {
        WindowGroup {
            coordinator.start()
        }
    }
}
