//
//  BaseCoreDataStack.swift
//  BaseSwiftUI
//
//  Created by Vu The Anh on 17/4/26.
//

import CoreData

final class BaseCoreDataStack {
    static let shared = BaseCoreDataStack()

    let persistentContainer: NSPersistentContainer

    private init(modelName: String = "BaseCoreData") {
        persistentContainer = NSPersistentContainer(name: modelName)

        if let description = persistentContainer.persistentStoreDescriptions.first {
            description.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
            description.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
        }

        persistentContainer.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Failed to load persistent stores: \(error)")
            }
        }

        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }

    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
}
