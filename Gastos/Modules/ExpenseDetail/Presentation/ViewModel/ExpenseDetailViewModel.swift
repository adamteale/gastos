//
//  ExpenseDetailViewModel.swift
//  Gastos
//
//  Created by Adam Teale on 25-11-22.
//

import Foundation
import Combine
import CoreData

final class ExpenseDetailViewModel: ObservableObject {

    @Published var amount: Double
    @Published var title: String
    @Published var category: Category?
    @Published var date: Date
    @Published var tags: Set<Tag>

    @Published var categories: [Category]
    @Published var availableTags: [Tag]

    @Published var activeCategory: Category?
    @Published var isPresentingCategory = false
    @Published var activeTag: Tag?
    @Published var isPresentingTag = false

    private(set) var expense: Expense?

    private(set) var managedObjectContext: NSManagedObjectContext
    private let fetchRequest: NSFetchRequest<Expense> = NSFetchRequest(entityName: String(describing: Category.self))
    private let cancelBag = CancelBag()

    init(
        expense: Expense?,
        categories: [Category],
        availableTags: [Tag],
        managedObjectContext: NSManagedObjectContext
    ) {
        self.expense = expense
        self.categories = categories
        self.availableTags = availableTags
        self.managedObjectContext = managedObjectContext

        amount = expense?.amount ?? 0
        title = expense?.title ?? ""
        date = expense?.date ?? Date()
        category = expense?.category
        tags = expense?.tags as? Set ?? Set<Tag>()
    }

    func onUpdate(title: String) {
        self.title = title
    }

    func onUpdate(amount: Double) {
        self.amount = amount
    }

    func onUpdate(tag: Tag) {
        if tags.contains(tag) {
            tags.remove(tag)
        } else {
            tags.insert(tag)
        }
    }

    func onUpdateCategory(atIndex index: Int) {
        self.category = categories[index]
    }

    func onSave(onSuccess: () -> Void ) {
        if expense == nil {
            expense = Expense(context: managedObjectContext)
        }
        expense?.title = title
        expense?.amount = amount
        expense?.category = category ?? categories.first
        expense?.tags = NSSet(set: tags)
        expense?.date = date
        do {
            try managedObjectContext.save()
            onSuccess()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    func onAddCategory() {
        activeCategory = nil
        isPresentingCategory = true
    }

    func onAddTag() {
        activeTag = nil
        isPresentingTag = true
    }

}
