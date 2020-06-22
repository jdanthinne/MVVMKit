//
//  DataSource.swift
//  Metronotes
//
//  Created by Jérôme Danthinne on 28/03/2020.
//  Copyright © 2020 Apptree. All rights reserved.
//

import CoreData
import UIKit

public enum FetchedResultsChange {
    case insert(indexPath: IndexPath)
    case update(indexPath: IndexPath)
    case move(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath)
    case delete(indexPath: IndexPath)
}

public enum FetchedResultsSectionChange {
    case insert(indexSet: IndexSet)
    case delete(indexPath: IndexSet)
}

public protocol FetchedResultsViewModelDelegate: AnyObject {
    func fetchedResultsViewModel(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                                 shouldCallObserverFor type: AnyClass) -> Bool
}

open class FetchedResultsViewModel<Model: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    open var viewContext: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<Model>
    public weak var delegate: FetchedResultsViewModelDelegate?

    public typealias Observer = (_ object: Model, _ change: FetchedResultsChange) -> Void
    var observer: Observer?

    public typealias SectionsObserver = (_ change: FetchedResultsSectionChange) -> Void
    var sectionsObserver: SectionsObserver?

    public typealias ChangeObserver = () -> Void
    var willChangeObserver: ChangeObserver?
    var didChangeObserver: ChangeObserver?

    public init(viewContext: NSManagedObjectContext,
                fetchRequest: NSFetchRequest<Model>,
                sectionNameKeyPath: String? = nil) {
        self.viewContext = viewContext
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: viewContext,
                                                              sectionNameKeyPath: sectionNameKeyPath,
                                                              cacheName: nil)
        super.init()

        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
    }

    // MARK: - Observers

    public func observe(_ observer: @escaping Observer) {
        self.observer = observer
    }

    public func sectionsObserve(_ observer: @escaping SectionsObserver) {
        sectionsObserver = observer
    }

    public func willChangeObserve(_ observer: @escaping ChangeObserver) {
        willChangeObserver = observer
    }

    public func didChangeObserve(_ observer: @escaping ChangeObserver) {
        didChangeObserver = observer
    }

    public func cancelObservers() {
        observer = nil
        sectionsObserver = nil
        willChangeObserver = nil
        didChangeObserver = nil
    }

    // MARK: - Getters

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
        viewContext.delete(object(at: indexPath))
        try! viewContext.save()
    }

    // MARK: - NSFetchedResultsControllerDelegate

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        willChangeObserver?()
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        didChangeObserver?()
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        if let sectionsObserver = sectionsObserver {
            switch type {
            case .insert:
                sectionsObserver(.insert(indexSet: IndexSet(integer: sectionIndex)))
            case .delete:
                sectionsObserver(.delete(indexPath: IndexSet(integer: sectionIndex)))
            default:
                break
            }
        }
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if delegate?.fetchedResultsViewModel(controller, shouldCallObserverFor: Model.self) ?? true,
            let observer = observer,
            let object = anObject as? Model {
            let change: FetchedResultsChange
            switch type {
            case .insert:
                change = .insert(indexPath: newIndexPath!)
            case .delete:
                change = .delete(indexPath: indexPath!)
            case .move:
                if indexPath == newIndexPath {
                    change = .update(indexPath: indexPath!)
                } else {
                    change = .move(sourceIndexPath: indexPath!, destinationIndexPath: newIndexPath!)
                }
            case .update:
                change = .update(indexPath: indexPath!)
            @unknown default:
                fatalError("Unhandled case")
            }

            observer(object, change)
        }
    }
}
