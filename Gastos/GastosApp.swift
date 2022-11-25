//
//  GastosApp.swift
//  Gastos
//
//  Created by Adam Teale on 25-11-22.
//

import SwiftUI

@main
struct GastosApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
