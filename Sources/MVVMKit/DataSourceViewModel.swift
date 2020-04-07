//
//  DataSource.swift
//  Metronotes
//
//  Created by Jérôme Danthinne on 28/03/2020.
//  Copyright © 2020 Apptree. All rights reserved.
//

import CoreData

open class DataSourceViewModel: NSObject {
    public enum Change {
        case insert(indexPath: IndexPath)
        case update(indexPath: IndexPath)
        case move(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath)
        case delete(indexPath: IndexPath)
    }

    public typealias Observer = (_ object: Any, _ change: Change) -> Void
    var observer: Observer?

    public func observe(observer: @escaping Observer) {
        self.observer = observer
    }

    open func shouldCallObserver<T: NSFetchRequestResult>(_ controller: NSFetchedResultsController<T>) -> Bool {
        true
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension DataSourceViewModel: NSFetchedResultsControllerDelegate {
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if shouldCallObserver(controller), let observer = observer {
            let change: Change
            switch type {
            case .insert:
                change = .insert(indexPath: newIndexPath!)
            case .delete:
                change = .delete(indexPath: indexPath!)
            case .move:
                change = .move(sourceIndexPath: indexPath!, destinationIndexPath: newIndexPath!)
            case .update:
                change = .update(indexPath: indexPath!)
            @unknown default:
                fatalError("Unhandled case")
            }

            observer(anObject, change)
        }
    }
}
