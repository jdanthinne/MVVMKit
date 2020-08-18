//
//  RelationshipKeyPath.swift
//
//
//  Created by Jérôme Danthinne on 18/08/2020.
//

import CoreData

/// Describes a relationship key path for a Core Data entity.
struct RelationshipKeyPath: Hashable {
    /// The source property name of the relationship entity we're observing.
    let sourcePropertyName: String

    let destinationEntityName: String

    /// The destination property name we're observing
    let destinationPropertyName: String

    /// The inverse property name of this relationship. Can be used to get the affected object IDs.
    let inverseRelationshipKeyPath: String

    init(keyPath: String, relationships: [String: NSRelationshipDescription]) {
        let splittedKeyPath = keyPath.split(separator: ".")
        sourcePropertyName = String(splittedKeyPath.first!)
        destinationPropertyName = String(splittedKeyPath.last!)

        let relationship = relationships[sourcePropertyName]!
        destinationEntityName = relationship.destinationEntity!.name!
        inverseRelationshipKeyPath = relationship.inverseRelationship!.name

        [sourcePropertyName, destinationEntityName, destinationPropertyName].forEach { property in
            assert(!property.isEmpty, "Invalid key path is used")
        }
    }
}
