//
//  DataSource.swift
//  Metronotes
//
//  Created by Jérôme Danthinne on 28/03/2020.
//  Copyright © 2020 Apptree. All rights reserved.
//

import CoreData

public class DataSourceViewModel: NSObject {
    enum Change {
        case insert(indexPath: IndexPath)
        case update(indexPath: IndexPath)
        case move(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath)
        case delete(indexPath: IndexPath)
    }

    typealias Observer = (_ object: Any, _ change: Change) -> Void
    var observer: Observer?

    func observe(observer: @escaping Observer) {
        self.observer = observer
    }

    func shouldCallObserver<T: NSFetchRequestResult>(_ controller: NSFetchedResultsController<T>) -> Bool {
        true
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension DataSourceViewModel: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
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
