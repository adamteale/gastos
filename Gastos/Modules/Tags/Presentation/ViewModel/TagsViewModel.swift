//
//  TagDetailViewModel.swift
//  Gastos
//
//  Created by Adam Teale on 25-11-22.
//

import Foundation
import Combine
import CoreData

final class TagDetailViewModel: ObservableObject {

    @Published var name: String
    @Published var alreadyExists: Bool
    @Published var tags: [Tag]
    @Published var activeTag: Tag?
    @Published var isPresentingTag = false

    private var tag: Tag?
    private(set) var managedObjectContext: NSManagedObjectContext

    private let fetchRequest: NSFetchRequest<Tag> = NSFetchRequest(entityName: String(describing: Tag.self))
    private let cancelBag = CancelBag()

    init(
        tag: Tag?,
        tags: [Tag],
        managedObjectContext: NSManagedObjectContext
    ) {
        self.tag = tag
        self.managedObjectContext = managedObjectContext
        self.tags = tags
        alreadyExists = false
        name = tag?.name ?? ""
    }

    func onUpdate(onSuccess: () -> Void) {
        // check if Tag with the same name already exists
        if (self.tags.first(where: { $0.name?.lowercased() == name.lowercased() }) != nil) {
            alreadyExists = true
        } else {
            alreadyExists = false
            if let tag = tag {
                print("saving existing Tag")
                tag.name = name
            } else {
                print("saving new Tag")
                let newItem = Tag(context: managedObjectContext)
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
        offsets.map { tags[$0] }.forEach(managedObjectContext.delete)
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
        activeTag = tags[index]
        isPresentingTag = true
    }
}
