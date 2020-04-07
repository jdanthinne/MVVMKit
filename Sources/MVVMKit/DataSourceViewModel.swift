//
//  DataSource.swift
//  Metronotes
//
//  Created by Jérôme Danthinne on 28/03/2020.
//  Copyright © 2020 Apptree. All rights reserved.
//

import CoreData
import UIKit

public protocol DataSourceViewModelDelegate: AnyObject {
    func shouldCallObserver(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                            for type: AnyClass) -> Bool
}

open class DataSourceViewModel<Model: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    private let moc: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<Model>
    public weak var delegate: DataSourceViewModelDelegate?
    
    public enum Change {
        case insert(indexPath: IndexPath)
        case update(indexPath: IndexPath)
        case move(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath)
        case delete(indexPath: IndexPath)
    }

    public typealias Observer = (_ object: Model, _ change: Change) -> Void
    var observer: Observer?
    
    public init(context: NSManagedObjectContext, fetchRequest: NSFetchRequest<Model>) {
        moc = context
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: moc,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        super.init()

        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
    }

    public func observe(_ observer: @escaping Observer) {
        self.observer = observer
    }

    public var dataSource: [Model] {
        fetchedResultsController.fetchedObjects ?? []
    }

    public func object(at indexPath: IndexPath) -> Model {
        dataSource[indexPath.row]
    }

    public func delete(at indexPath: IndexPath) {
        moc.delete(object(at: indexPath))
        try! moc.save()
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if delegate?.shouldCallObserver(controller, for: Model.self) ?? true,
            let observer = observer,
            let object = anObject as? Model {

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

            observer(object, change)
        }
    }
}
