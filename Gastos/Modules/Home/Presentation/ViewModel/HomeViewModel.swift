//
//  HomeViewModel.swift
//  Gastos
//
//  Created by Adam Teale on 25-11-22.
//

import Foundation
import CloudKit
import CoreData
import Combine

final class HomeViewModel: ObservableObject {

    @Published var expensesSections = [String: [Expense]]()
    @Published var activeExpense: Expense?
    @Published var activeCategory: Category?
    @Published var activeTag: Tag?
    @Published var activeAccount: Account?

    @Published var isPresentingExpense = false
    @Published var isPresentingCategory = false
    @Published var isPresentingTag = false
    @Published var isPresentingAccount = false

    @Published var searchTerm: String = ""

    @Published var totalAmount: Double = 0.0

    private var expensesRaw = [Expense]()

    private(set) var categories = [Category]()
    private(set) var availableTags = [Tag]()
    private(set) var accounts = [Account]()

    private(set) var managedObjectContext: NSManagedObjectContext
    private let expensesFetchRequest: NSFetchRequest<Expense> = NSFetchRequest(
        entityName: String(describing: Expense.self)
    )
    private let categoriesFetchRequest: NSFetchRequest<Category> = NSFetchRequest(
        entityName: String(describing: Category.self)
    )
    private let tagsFetchRequest: NSFetchRequest<Tag> = NSFetchRequest(
        entityName: String(describing: Tag.self)
    )
    private let accountsFetchRequest: NSFetchRequest<Account> = NSFetchRequest(
        entityName: String(describing: Account.self)
    )

    private let cancelBag = CancelBag()
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext

        NotificationCenter.default
            .publisher(for: .NSManagedObjectContextDidSave,
                       object: managedObjectContext)
            .sink(receiveValue: { [weak self] notification in
                self?.onRefresh()
            }).store(in: cancelBag)
    }

    func onRefresh() {
        do {
            expensesRaw = try managedObjectContext.fetch(expensesFetchRequest).sorted(by: { lhs, rhs in
                lhs.date ?? Date() < rhs.date ?? Date()
            })

            categories = try managedObjectContext.fetch(categoriesFetchRequest)
            availableTags = try managedObjectContext.fetch(tagsFetchRequest)
            accounts = try managedObjectContext.fetch(accountsFetchRequest)
            onUpdate(searchTerm: "")
        } catch {
            print("error:", error)
        }
    }

    func onAddExpense() {
        activeExpense = nil
        isPresentingExpense = true
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

    func onEditItem(objectID: NSManagedObjectID) {
        activeExpense = expensesRaw.first(where: {$0.objectID == objectID})
        isPresentingExpense = true
    }

    func onEditItem(_ expense: Expense) {
        activeExpense = expense
        isPresentingExpense = true
    }

    func deleteItems(objectID: NSManagedObjectID) {
        guard let expense_to_delete = expensesRaw.first(where: {$0.objectID == objectID}) else { return }
        [expense_to_delete].forEach(managedObjectContext.delete)
        do {
            try managedObjectContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    func onUpdate(searchTerm: String) {
        self.searchTerm = searchTerm

        let k = expensesRaw.reduce(into: ([String: [Expense]](), 0.0), { partialResult, expense in
            if let date = Formatters.onlyDate.string(for: expense.date ?? Date()) {
                if partialResult.0[date] == nil {
                    partialResult.0[date] = []
                }

                if searchTerm.isEmpty {
                    partialResult.0[date]?.append(expense)
                    partialResult.1 += expense.amount
                } else if (expense.title ?? "" ).contains(searchTerm){
                    partialResult.0[date]?.append(expense)
                    partialResult.1 += expense.amount
                }
            }

        })

        expensesSections = k.0
        totalAmount = k.1
    }

    func onClearSearchTerm() {
        searchTerm = ""
    }
}
