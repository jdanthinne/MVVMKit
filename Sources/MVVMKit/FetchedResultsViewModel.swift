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
    open var viewContext: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<Model>
    public weak var delegate: FetchedResultsViewModelDelegate?

    public typealias ChangeObserver = () -> Void
    var observer: ChangeObserver?

    public init(viewContext: NSManagedObjectContext,
                fetchRequest: NSFetchRequest<Model>,
                sectionNameKeyPath: String? = nil) throws {
        self.viewContext = viewContext
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: viewContext,
                                                              sectionNameKeyPath: sectionNameKeyPath,
                                                              cacheName: nil)
        super.init()

        fetchedResultsController.delegate = self
        try fetchedResultsController.performFetch()
    }

    // MARK: - Observers

    public func observe(_ observer: @escaping ChangeObserver) {
        self.observer = observer
    }

    public func cancelObservers() {
        observer = nil
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

    public func delete(at indexPath: IndexPath) throws {
        viewContext.delete(object(at: indexPath))
        try viewContext.save()
    }

    // MARK: - NSFetchedResultsControllerDelegate

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if delegate?.fetchedResultsViewModel(controller, shouldCallObserverFor: Model.self) ?? true {
            observer?()
        }
    }
}
