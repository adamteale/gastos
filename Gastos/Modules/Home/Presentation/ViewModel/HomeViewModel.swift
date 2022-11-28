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

struct ExpensesSectionViewArgs {
    let date: Date
    let dateFormatted: String
    var expenses: [Expense]
}

struct TDumpEntry: Decodable{
    let date: [String]
    let account: [String]
    let category: [String]
    let tags: [String]
    let ammount: [String]
    let currency: [String]
    let ammountOriginal: [String]
    let currencyOriginal: [String]
    let description: [String]
}

struct TDump: Decodable{
    let items: [TDumpEntry]
}

final class HomeViewModel: ObservableObject {

    @Published var expensesSections = [ExpensesSectionViewArgs]()
    @Published var activeExpense: Expense?
    @Published var activeCategory: Category?
    @Published var activeTag: Tag?
    @Published var activeAccount: Account?

    @Published var selectedDate: Date = Date()

    @Published var isPresentingExpense = false
    @Published var isPresentingCategory = false
    @Published var isPresentingTag = false
    @Published var isPresentingAccount = false

    @Published var searchTerm: String = ""

    @Published var totalAmount: Double = 0.0

    let months: [String] = Calendar.current.shortMonthSymbols

    private let calendar = Calendar.current
    private var expensesRaw = [Expense]()
    private(set) var categories = [Category]()
    private(set) var availableTags = [Tag]()
    private(set) var accounts = [Account]()
    private(set) var managedObjectContext: NSManagedObjectContext
    private let cancelBag = CancelBag()

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

    private var initialLoadComplete = false
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext

        NotificationCenter.default
            .publisher(for: .NSManagedObjectContextDidSave,
                       object: managedObjectContext)
            .sink(receiveValue: { [weak self] notification in
                self?.onRefresh()
            }).store(in: cancelBag)

    }

    func delete() {
        var stuff = [String: Category]()
        categories.forEach {
            guard let name = $0.name else { return }
            if stuff[name] == nil {
                stuff[name] = $0
            } else {
                [$0].forEach(managedObjectContext.delete)
            }
        }

        var tags = [String: Tag]()
        availableTags.forEach {
            [$0].forEach(managedObjectContext.delete)
            guard let name = $0.name else { return }
            if tags[name] == nil {
//                print(name, $0.name)
                tags[name] = $0
            } else {
                [$0].forEach(managedObjectContext.delete)
            }
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

    func readJson() {
        let path = Bundle.main.path(forResource: "toshl", ofType: "json") // file path for file "data.txt"

        let string = try? String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        guard let data = string?.data(using: .utf8) else { return }
        do {
            let p = try JSONDecoder().decode(TDump.self, from: data)

            for (index, item) in p.items.enumerated() {
                if let name = item.category.first {

                    if categories.first(where: { $0.name == name }) == nil {
                        do {
                            let newItem = Category(context: managedObjectContext)
                            newItem.name = name
                            try managedObjectContext.save()
//                            categories = try managedObjectContext.fetch(categoriesFetchRequest)
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }
//                    else {
//                        print("duplicate category", name, index)
//                    }

                }

                for (index, tag) in item.tags.enumerated() {
                    if tag != "\n" && !tag.isEmpty && !(tag == " ") && !(tag.count == 0) {
                        if availableTags.first(where: { $0.name == tag }) == nil {
                            print("tag:", tag, tag)
                            do {
                                let newItem = Tag(context: managedObjectContext)
                                newItem.name = tag.replacingOccurrences(of: "\n", with: "")
                                try managedObjectContext.save()
                                //                                availableTags = try managedObjectContext.fetch(tagsFetchRequest)
                            } catch {
                                let nsError = error as NSError
                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                            }
                        }
//                        else {
//                            print("duplicate tag", tag, index)
//                        }

                    }

                }
            }

        } catch {
            print(error)
        }

    }

    func onRefresh() {
        do {
            expensesRaw = try managedObjectContext.fetch(expensesFetchRequest)
            categories = try managedObjectContext.fetch(categoriesFetchRequest)
                .sorted { $0.name?.lowercased() ?? "" < $1.name?.lowercased() ?? "" }
            availableTags = try managedObjectContext.fetch(tagsFetchRequest)
                .sorted { $0.name?.lowercased() ?? "" < $1.name?.lowercased() ?? "" }
            accounts = try managedObjectContext.fetch(accountsFetchRequest)
                .sorted { $0.name?.lowercased() ?? "" < $1.name?.lowercased() ?? "" }
            onUpdate(searchTerm: "")

            if !initialLoadComplete {
                initialLoadComplete = true

//                delete()
//                readJson()
            }


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

        let k = expensesRaw.filter { expense in
            calendar.isDate(expense.date ?? Date(), equalTo: selectedDate, toGranularity: .month)
        }.reduce(into: ([String: ExpensesSectionViewArgs](), 0.0), { partialResult, expense in

            if let dateFormatted = Formatters.dateSectionFormatting.string(for: expense.date ?? Date()) {

                let dateComponents = calendar.dateComponents([.month, .day, .year], from: expense.date ?? Date())
                let keyDate = calendar.date(from: dateComponents) ?? Date()

                if partialResult.0[dateFormatted] == nil {
                    partialResult.0[dateFormatted] = ExpensesSectionViewArgs(
                        date: keyDate,
                        dateFormatted: {
                            if let expenseDate = expense.date {
                                return Formatters.onlyDate.string(for: expenseDate) ?? dateFormatted
                            } else {
                                return dateFormatted
                            }
                        }(),
                        expenses: []
                    )
                }

                if searchTerm.isEmpty {
                    partialResult.0[dateFormatted]?.expenses.append(expense)
                    partialResult.1 += expense.amount
                } else if (expense.title ?? "" ).contains(searchTerm){
                    partialResult.0[dateFormatted]?.expenses.append(expense)
                    partialResult.1 += expense.amount
                }
            }

        })
        expensesSections = Array(k.0.map({ (key: String, value: ExpensesSectionViewArgs) in
            value
        })).sorted { $0.date > $1.date }

        totalAmount = k.1

    }

    func onClearSearchTerm() {
        searchTerm = ""
    }

    func onChangeCurrentDate(date: Date) {
        var dateComponents = calendar.dateComponents([.month, .day, .year], from: date)
        dateComponents.day = 1
        selectedDate = calendar.date(from: dateComponents) ?? Date()
        onUpdate(searchTerm: searchTerm)
    }

}
