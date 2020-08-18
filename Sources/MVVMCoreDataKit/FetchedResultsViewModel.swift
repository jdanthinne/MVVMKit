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
    public let viewContext: NSManagedObjectContext
    private let fetchedResultsController: RichFetchedResultsController<Model>
    public weak var delegate: FetchedResultsViewModelDelegate?

    public typealias ChangeObserver = (_ objects: [Model]) -> Void
    private var observer: ChangeObserver?

    public var objects: [Model]

    public init(viewContext: NSManagedObjectContext,
                fetchRequest: NSFetchRequest<Model>,
                relationshipKeyPathsForRefreshing: Set<String> = []) throws {
        self.viewContext = viewContext

        let richRequest = RichFetchRequest<Model>.from(fetchRequest,
                                                       relationshipKeyPathsForRefreshing: relationshipKeyPathsForRefreshing)

        fetchedResultsController = RichFetchedResultsController(fetchRequest: richRequest,
                                                                managedObjectContext: viewContext,
                                                                sectionNameKeyPath: nil,
                                                                cacheName: nil)
        try fetchedResultsController.performFetch()
        objects = fetchedResultsController.fetchedObjects as? [Model] ?? []

        super.init()
        fetchedResultsController.delegate = self
    }

    // MARK: - Observers

    public func observe(_ observer: @escaping ChangeObserver) {
        self.observer = observer
        observer(objects)
    }

    public func cancelObservers() {
        observer = nil
    }

    // MARK: - Getters

    public var numberOfObjects: Int {
        objects.count
    }

    public var isEmpty: Bool {
        objects.isEmpty
    }

    public func object(at indexPath: IndexPath) throws -> Model {
        guard indexPath.row < numberOfObjects else {
            throw FetchedResultViewModelError.noObjectAtIndexPath
        }

        return objects[indexPath.row]
    }

    public func delete(at indexPath: IndexPath) throws {
        try viewContext.delete(object(at: indexPath))
        try viewContext.save()
    }

    // MARK: - NSFetchedResultsControllerDelegate

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        objects = controller.fetchedObjects as? [Model] ?? []

        if delegate?.fetchedResultsViewModel(controller, shouldCallObserverFor: Model.self) ?? true {
            observer?(objects)
        }
    }
}
