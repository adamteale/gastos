//
//  TagCloudable.swift
//  Gastos
//
//  Created by Adam Teale on 27-11-22.
//

import CoreData

protocol TagCloudable: Hashable {
    var name: String? { get }
    var objectID: NSManagedObjectID { get }
}
