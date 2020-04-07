//
//  DataSource.swift
//  Metronotes
//
//  Created by Jérôme Danthinne on 28/03/2020.
//  Copyright © 2020 Apptree. All rights reserved.
//

import CoreData
import UIKit

public protocol FetchedResultsViewModelDelegate: AnyObject {
    func fetchedResultsViewModel(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                                 shouldCallObserverFor type: AnyClass) -> Bool
}

open class FetchedResultsViewModel<Model: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    open var moc: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<Model>
    public weak var delegate: FetchedResultsViewModelDelegate?
    
    public enum Change {
        case insert(indexPath: IndexPath)
        case update(indexPath: IndexPath)
        case move(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath)
        case delete(indexPath: IndexPath)
    }

    public typealias Observer = (_ object: Model, _ change: Change) -> Void
    var observer: Observer?
    
    public init(context: NSManagedObjectContext,
                fetchRequest: NSFetchRequest<Model>,
                sectionNameKeyPath: String? = nil) {
        moc = context
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: moc,
                                                              sectionNameKeyPath: sectionNameKeyPath,
                                                              cacheName: nil)
        super.init()

        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
    }

    public func observe(_ observer: @escaping Observer) {
        self.observer = observer
    }

    open var fetchedObjects: [Model] {
        fetchedResultsController.fetchedObjects ?? []
    }
    public var numberOfObjects: Int {
        fetchedObjects.count
    }
    public var isEmpty: Bool {
        fetchedObjects.isEmpty
    }
    
    public var numberOfSections: Int {
        fetchedResultsController.sections!.count
    }
    func sectionInfo(at section: Int) -> NSFetchedResultsSectionInfo {
        fetchedResultsController.sections![section]
    }
    public var sectionsTitles: [String] {
        fetchedResultsController.sections!.map(\.name)
    }
    public func titleOfSection(at section: Int) -> String? {
        sectionInfo(at: section).name
    }
    func objects(in section: Int) -> [Model] {
        sectionInfo(at: section).objects as! [Model]
    }
    public func numberOfObjects(in section: Int) -> Int {
        objects(in: section).count
    }

    public func object(at indexPath: IndexPath) -> Model {
        objects(in: indexPath.section)[indexPath.row]
    }

    public func delete(at indexPath: IndexPath) {
        moc.delete(object(at: indexPath))
        try! moc.save()
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if delegate?.fetchedResultsViewModel(controller, shouldCallObserverFor: Model.self) ?? true,
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
