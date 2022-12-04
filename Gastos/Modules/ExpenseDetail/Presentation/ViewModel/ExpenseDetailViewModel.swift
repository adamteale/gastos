//
//  ExpenseDetailViewModel.swift
//  Gastos
//
//  Created by Adam Teale on 25-11-22.
//

import Foundation
import Combine
import CoreData

struct ExpenseDetailViewModelArgs {
    let expense: Expense?
    let categories: [Category]
    let availableTags: [Tag]
    let availableAccounts: [Account]
    let managedObjectContext: NSManagedObjectContext
    let onSaveSuccess: () -> Void
    let onSceneChange: (HomeCoordinator.Scene) -> Void
}

final class ExpenseDetailViewModel: ObservableObject {

    @Published var amount: Double?
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
    private let onSaveSuccess: () -> Void

    private let onSceneChange: (HomeCoordinator.Scene) -> Void

    init(args: ExpenseDetailViewModelArgs) {
        expense = args.expense
        availableCategories = args.categories
        availableTags = args.availableTags
        availableAccounts = args.availableAccounts
        managedObjectContext = args.managedObjectContext
        onSaveSuccess = args.onSaveSuccess
        onSceneChange = args.onSceneChange

        amount = expense?.amount
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

    func onSave(shouldDimiss: Bool = false, forceSave: Bool = false) {
        if shouldDimiss && expense == nil && !forceSave {
            return
        } else {
            guard let amount = amount else { return }
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
                if shouldDimiss {
                    onSaveSuccess()
                }
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    func onAddCategory() {
        activeCategory = nil
        isPresentingCategory = true
        onSceneChange(HomeCoordinator.Scene.categoryDetail(nil))
    }

    func onAddTag() {
        activeTag = nil
        isPresentingTag = true
        onSceneChange(HomeCoordinator.Scene.tagDetail(nil))
    }

    func onAddAccount() {
        activeAccount = nil
        isPresentingAccount = true
        onSceneChange(HomeCoordinator.Scene.accountDetail(nil))

    }

    func onEditCategory(category: Category) {
        activeCategory = category
        isPresentingCategory = true
        onSceneChange(HomeCoordinator.Scene.categoryDetail(category))
    }

    func onEditTag(tag: Tag) {
        activeTag = tag
        isPresentingTag = true
        onSceneChange(HomeCoordinator.Scene.tagDetail(tag))
    }

    func onEditAccount(account: Account) {
        activeAccount = account
        isPresentingAccount = true
        onSceneChange(HomeCoordinator.Scene.accountDetail(account))
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
