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
    @Published var account: Account?
    @Published var date: Date
    @Published var tags: Set<Tag>

    @Published var availableCategories: [Category]
    @Published var availableTags: [Tag]
    @Published var availableAccounts: [Account]
    @Published var activeCategory: Category?
    @Published var isPresentingCategory = false
    @Published var activeTag: Tag?
    @Published var isPresentingTag = false

    @Published var activeAccount: Account?
    @Published var isPresentingAccount = false
    private(set) var expense: Expense?

    private(set) var managedObjectContext: NSManagedObjectContext
    private let fetchRequest: NSFetchRequest<Expense> = NSFetchRequest(entityName: String(describing: Category.self))
    private let cancelBag = CancelBag()

    init(
        expense: Expense?,
        categories: [Category],
        availableTags: [Tag],
        availableAccounts: [Account],
        managedObjectContext: NSManagedObjectContext
    ) {
        self.expense = expense
        self.availableCategories = categories
        self.availableTags = availableTags
        self.availableAccounts = availableAccounts
        self.managedObjectContext = managedObjectContext

        amount = expense?.amount ?? 0
        title = expense?.title ?? ""
        date = expense?.date ?? Date()
        category = expense?.category
        account = expense?.account
        tags = expense?.tags as? Set ?? Set<Tag>()
    }

    func onUpdateAmount(_ amount: Double) {
        self.amount = amount
    }

    func onUpdateTag(_ tag: Tag) {
        if tags.contains(tag) {
            tags.remove(tag)
        } else {
            tags.insert(tag)
        }
    }

    func onUpdateCategory(_ category: Category) {
        self.category = category
    }

    func onUpdateAccount(_ account: Account) {
        self.account = account
    }

    func onSave(onSuccess: () -> Void ) {
        if expense == nil {
            expense = Expense(context: managedObjectContext)
        }
        expense?.title = title
        expense?.amount = amount
        expense?.category = category ?? availableCategories.first
        expense?.tags = NSSet(set: tags)
        expense?.date = date
        expense?.account = account

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

    func onAddAccount() {
        activeAccount = nil
        isPresentingAccount = true
    }

    func onEditCategory(category: Category) {
        activeCategory = category
        isPresentingCategory = true
    }

    func onEditTag(tag: Tag) {
        activeTag = tag
        isPresentingTag = true
    }

    func onEditAccount(account: Account) {
        activeAccount = account
        isPresentingAccount = true
    }

    func onDelete() {
        if let expense = expense {
            [expense].forEach(managedObjectContext.delete)
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
    }
}
