//
//  CategoryDetailViewModel.swift
//  Gastos
//
//  Created by Adam Teale on 25-11-22.
//

import Foundation
import Combine
import CoreData

final class CategoryDetailViewModel: ObservableObject {

    @Published var name: String
    @Published var alreadyExists: Bool
    @Published var categories: [Category]
    @Published var activeCategory: Category?
    @Published var isPresentingCategory = false

    private(set) var category: Category?
    private(set) var managedObjectContext: NSManagedObjectContext

    private let fetchRequest: NSFetchRequest<Category> = NSFetchRequest(entityName: String(describing: Category.self))
    private let cancelBag = CancelBag()

    init(
        category: Category?,
        categories: [Category],
        managedObjectContext: NSManagedObjectContext
    ) {
        self.category = category
        self.managedObjectContext = managedObjectContext
        self.categories = categories
        alreadyExists = false
        name = category?.name ?? ""
    }

    func onUpdate() {
        // check if category with the same name already exists
        if (self.categories.first(where: { $0.name?.lowercased() == name.lowercased() }) != nil) {
            alreadyExists = true
        } else {
            alreadyExists = false
            if let category = category {
                print("saving existing category")
                category.name = name
            } else {
                print("saving new category")
                let newItem = Category(context: managedObjectContext)
                newItem.name = name
            }
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }

        }
    }

    func deleteItems(offsets: IndexSet) {
        offsets.map { categories[$0] }.forEach(managedObjectContext.delete)
        do {
            try managedObjectContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    func onEditItem(at index: Int) {
        activeCategory = categories[index]
        isPresentingCategory = true
    }

    func onDelete() {
        if let category = category {
            [category].forEach(managedObjectContext.delete)
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
    }
}
