//
//  Set+NSManagedObject.swift
//
//
//  Created by Jérôme Danthinne on 18/08/2020.
//

import CoreData

extension Set where Element: NSManagedObject {
    /// Iterates over the objects and returns the object IDs that matched our observing keyPaths.
    /// - Parameter keyPaths: The keyPaths to observe changes for.
    func updatedObjectIDs(for keyPaths: Set<RelationshipKeyPath>) -> Set<NSManagedObjectID>? {
        var objectIDs: Set<NSManagedObjectID> = []
        forEach { object in
            guard let changedRelationshipKeyPath = object.changedKeyPath(from: keyPaths) else { return }

            let value = object.value(forKey: changedRelationshipKeyPath.inverseRelationshipKeyPath)
            if let toManyObjects = value as? Set<NSManagedObject> {
                toManyObjects.forEach {
                    objectIDs.insert($0.objectID)
                }
            } else if let toOneObject = value as? NSManagedObject {
                objectIDs.insert(toOneObject.objectID)
            } else {
                assertionFailure("Invalid relationship observed for keyPath: \(changedRelationshipKeyPath)")
                return
            }
        }

        return objectIDs
    }
}

private extension NSManagedObject {
    /// Matches the given key paths to the current changes of this `NSManagedObject`.
    /// - Parameter keyPaths: The key paths to match the changes for.
    /// - Returns: The matching relationship key path if found. Otherwise, `nil`.
    func changedKeyPath(from keyPaths: Set<RelationshipKeyPath>) -> RelationshipKeyPath? {
        keyPaths.first { keyPath -> Bool in
            guard keyPath.destinationEntityName == entity.name! || keyPath.destinationEntityName == entity.superentity?.name else { return false }
            return changedValues().keys.contains(keyPath.destinationPropertyName)
        }
    }
}
