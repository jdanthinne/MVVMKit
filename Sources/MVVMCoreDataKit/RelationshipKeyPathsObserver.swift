//
//  RelationshipKeyPathsObserver.swift
//
//
//  Created by Jérôme Danthinne on 18/08/2020.
//

import CoreData

/// Observes relationship key paths and refreshes Core Data objects accordingly once the related managed object context saves.
final class RelationshipKeyPathsObserver<ResultType: NSFetchRequestResult>: NSObject {
    private let keyPaths: Set<RelationshipKeyPath>
    private unowned let fetchedResultsController: RichFetchedResultsController<ResultType>

    private var updatedObjectIDs: Set<NSManagedObjectID> = []

    init?(keyPaths: Set<String>, fetchedResultsController: RichFetchedResultsController<ResultType>) {
        guard !keyPaths.isEmpty else { return nil }

        let relationships = fetchedResultsController.fetchRequest.entity!.relationshipsByName
        self.keyPaths = Set(keyPaths.map { keyPath in
            RelationshipKeyPath(keyPath: keyPath, relationships: relationships)
        })
        self.fetchedResultsController = fetchedResultsController

        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(contextDidChangeNotification(notification:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: fetchedResultsController.managedObjectContext)
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSaveNotification(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: fetchedResultsController.managedObjectContext)
    }

    @objc private func contextDidChangeNotification(notification: NSNotification) {
        guard let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> else { return }
        guard let updatedObjectIDs = updatedObjects.updatedObjectIDs(for: keyPaths), !updatedObjectIDs.isEmpty else { return }
        self.updatedObjectIDs = self.updatedObjectIDs.union(updatedObjectIDs)
    }

    @objc private func contextDidSaveNotification(notification: NSNotification) {
        guard !updatedObjectIDs.isEmpty else { return }
        guard let fetchedObjects = fetchedResultsController.fetchedObjects as? [NSManagedObject], !fetchedObjects.isEmpty else { return }

        fetchedObjects.forEach { object in
            guard updatedObjectIDs.contains(object.objectID) else { return }
            fetchedResultsController.managedObjectContext.refresh(object, mergeChanges: true)
        }
        updatedObjectIDs.removeAll()
    }
}
