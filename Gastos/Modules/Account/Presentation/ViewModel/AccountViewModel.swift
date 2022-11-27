//
//  AccountDetailViewModel.swift
//  Gastos
//
//  Created by Adam Teale on 25-11-22.
//

import Foundation
import Combine
import CoreData

final class AccountDetailViewModel: ObservableObject {

    @Published var name: String
    @Published var alreadyExists: Bool
    @Published var accounts: [Account]
    @Published var activeAccount: Account?
    @Published var isPresentingAccount = false

    private var account: Account?
    private(set) var managedObjectContext: NSManagedObjectContext

    private let fetchRequest: NSFetchRequest<Account> = NSFetchRequest(entityName: String(describing: Account.self))
    private let cancelBag = CancelBag()

    init(
        account: Account?,
        accounts: [Account],
        managedObjectContext: NSManagedObjectContext
    ) {
        self.account = account
        self.managedObjectContext = managedObjectContext
        self.accounts = accounts
        alreadyExists = false
        name = account?.name ?? ""
    }

    func onUpdate(onSuccess: () -> Void) {
        // check if account with the same name already exists
        if (self.accounts.first(where: { $0.name?.lowercased() == name.lowercased() }) != nil) {
            alreadyExists = true
        } else {
            alreadyExists = false
            if let account = account {
                print("saving existing account")
                account.name = name
            } else {
                print("saving new account")
                let newItem = Account(context: managedObjectContext)
                newItem.name = name
            }
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
    }

    func deleteItems(offsets: IndexSet) {
        offsets.map { accounts[$0] }.forEach(managedObjectContext.delete)
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
        activeAccount = accounts[index]
        isPresentingAccount = true
    }
}
