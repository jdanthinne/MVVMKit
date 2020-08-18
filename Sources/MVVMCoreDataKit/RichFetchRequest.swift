//
//  RichFetchRequest.swift
//
//
//  Created by Jérôme Danthinne on 18/08/2020.
//

import CoreData

/// An enhanced `NSFetchRequest` that has extra functionality.
public final class RichFetchRequest<ResultType>: NSFetchRequest<NSFetchRequestResult> where ResultType: NSFetchRequestResult {
    /// A set of relationship key paths to observe when using a `RichFetchedResultsController`.
    public var relationshipKeyPathsForRefreshing: Set<String> = []

    init(_ fetchRequest: NSFetchRequest<ResultType>, relationshipKeyPathsForRefreshing: Set<String>) {
        super.init()

        entity = fetchRequest.entity
        predicate = fetchRequest.predicate
        sortDescriptors = fetchRequest.sortDescriptors

        fetchBatchSize = fetchRequest.fetchBatchSize
        fetchLimit = fetchRequest.fetchLimit
        fetchOffset = fetchRequest.fetchOffset
        propertiesToFetch = fetchRequest.propertiesToFetch
        propertiesToGroupBy = fetchRequest.propertiesToGroupBy

        self.relationshipKeyPathsForRefreshing = relationshipKeyPathsForRefreshing
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
