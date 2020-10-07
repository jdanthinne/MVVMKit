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
    var relationshipKeyPathsForRefreshing: Set<String> = []

    public static func from(_ fetchRequest: NSFetchRequest<ResultType>, relationshipKeyPathsForRefreshing: Set<String>) -> RichFetchRequest<ResultType> {
        let richRequest = RichFetchRequest<ResultType>(entityName: fetchRequest.entityName!)

        richRequest.predicate = fetchRequest.predicate
        richRequest.sortDescriptors = fetchRequest.sortDescriptors

        richRequest.fetchBatchSize = fetchRequest.fetchBatchSize
        richRequest.fetchLimit = fetchRequest.fetchLimit
        richRequest.fetchOffset = fetchRequest.fetchOffset
        richRequest.propertiesToFetch = fetchRequest.propertiesToFetch
        richRequest.propertiesToGroupBy = fetchRequest.propertiesToGroupBy

        richRequest.relationshipKeyPathsForRefreshing = relationshipKeyPathsForRefreshing

        return richRequest
    }
}
