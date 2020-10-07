//
//  RichFetchedResultsController.swift
//
//
//  Created by Jérôme Danthinne on 18/08/2020.
//

import CoreData

/// An enhanced `NSFetchedResultsController` that has extra functionality.
public class RichFetchedResultsController<ResultType: NSFetchRequestResult>: NSFetchedResultsController<NSFetchRequestResult> {
    /// The relationship key paths observer that is only initialised if the fetch request has a `relationshipKeyPathsForRefreshing` set.
    private var relationshipKeyPathsObserver: RelationshipKeyPathsObserver<ResultType>?

    public init(fetchRequest: RichFetchRequest<ResultType>, managedObjectContext context: NSManagedObjectContext, sectionNameKeyPath: String?, cacheName name: String?) {
        super.init(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: name)

        relationshipKeyPathsObserver = RelationshipKeyPathsObserver<ResultType>(keyPaths: fetchRequest.relationshipKeyPathsForRefreshing, fetchedResultsController: self)
    }
}
