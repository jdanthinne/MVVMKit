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
}
