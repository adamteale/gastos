//
//  DIContainer.swift
//  Gastos
//
//  Created by Adam Teale on 03-12-22.
//

import Foundation

final class DIEntry {
    
    let factory: Any

    init(
        factory: Any
    ) {
        self.factory = factory
    }
}

protocol DIContainerResolver {
    func resolve<Component>(type: Component.Type) -> Component?
    func resolve<Component, Args>(type: Component.Type, args: Args) -> Component?
}

protocol DIContainerProtocol: DIContainerResolver {
    func register<Component>(
        type: Component.Type,
        factory: @escaping (_ resolver: DIContainerResolver) -> Component
    )
    func register<Component, Args>(
        type: Component.Type,
        factory: @escaping (_ resolver: DIContainerResolver, _ args: Args) -> Component
    )
}

final class DIContainer: DIContainerProtocol {

    static let shared = DIContainer()

    private init() {}

    private var components: [String: DIEntry] = [:]

    func resolve<Component>(type: Component.Type) -> Component? {
        let component = components["\(type)"]
        let factory = component!.factory as! (_ resolver: DIContainerResolver) -> Component
        return factory(self)
    }

    func resolve<Component, Args>(type: Component.Type, args: Args) -> Component? {
        let component = components["\(type)"]
        let factory = component!.factory as! (DIContainerResolver, Args) -> Component
        return factory(self, args)
    }

    func register<Component>(
        type: Component.Type,
        factory: @escaping (_ resolver: DIContainerResolver) -> Component
    ) {
        let entry = DIEntry(
            factory: factory
        )
        components["\(type)"] = entry
    }

    func register<Component, Args>(
        type: Component.Type,
        factory: @escaping (_ resolver: DIContainerResolver, _ args: Args) -> Component
    ) {
        let entry = DIEntry(
            factory: factory
        )
        components["\(type)"] = entry
    }

}
