//
//  DataSource.swift
//  Metronotes
//
//  Created by Jérôme Danthinne on 28/03/2020.
//  Copyright © 2020 Apptree. All rights reserved.
//

import CoreData
import UIKit

open class SectionnedFetchedResultsViewModel<Model: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    public let viewContext: NSManagedObjectContext
    private let fetchedResultsController: RichFetchedResultsController<Model>
    public weak var delegate: FetchedResultsViewModelDelegate?

    public typealias ChangeObserver = (_ objects: [ModelSection]) -> Void
    private var observer: ChangeObserver?

    public typealias ModelSection = (title: String, elements: [Model])
    private var sections = [ModelSection]()

    public init(viewContext: NSManagedObjectContext,
                fetchRequest: NSFetchRequest<Model>,
                sectionNameKeyPath: String,
                relationshipKeyPathsForRefreshing: Set<String> = []) throws {
        self.viewContext = viewContext

        let richRequest = RichFetchRequest<Model>(fetchRequest,
                                                  relationshipKeyPathsForRefreshing: relationshipKeyPathsForRefreshing)

        fetchedResultsController = RichFetchedResultsController(fetchRequest: richRequest,
                                                                managedObjectContext: viewContext,
                                                                sectionNameKeyPath: sectionNameKeyPath,
                                                                cacheName: nil)

        super.init()

        fetchedResultsController.delegate = self
        try fetchedResultsController.performFetch()
        sections = arraySections(from: fetchedResultsController.sections)
    }

    // MARK: - Helpers

    private func arraySections(from sectionsInfo: [NSFetchedResultsSectionInfo]?) -> [ModelSection] {
        sectionsInfo?.compactMap { section -> ModelSection? in
            guard let objects = section.objects as? [Model] else { return nil }
            return (title: section.name, elements: objects)
        } ?? []
    }

    // MARK: - Observers

    public func observe(_ observer: @escaping ChangeObserver) {
        self.observer = observer
        observer(sections)
    }

    public func cancelObservers() {
        observer = nil
    }

    // MARK: - Getters

    public var objects: [Model] {
        sections.flatMap { $0.elements }
    }

    public var numberOfSections: Int {
        sections.count
    }

    public func titleOfSection(at section: Int) -> String? {
        guard section < sections.count else { return nil }
        return sections[section].title
    }

    public var sectionsTitles: [String] {
        sections.map(\.title)
    }

    func objects(in section: Int) throws -> [Model] {
        guard section < sections.count else {
            throw FetchedResultViewModelError.noSectionAtIndex
        }

        return sections[section].elements
    }

    public func numberOfObjects(in section: Int) throws -> Int {
        try objects(in: section).count
    }

    public func object(at indexPath: IndexPath) throws -> Model {
        let sectionObjects = try objects(in: indexPath.section)

        guard indexPath.row < sectionObjects.count else {
            throw FetchedResultViewModelError.noObjectAtIndexPath
        }

        return sectionObjects[indexPath.row]
    }

    public func delete(at indexPath: IndexPath) throws {
        try viewContext.delete(object(at: indexPath))
        try viewContext.save()
    }

    // MARK: - NSFetchedResultsControllerDelegate

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sections = arraySections(from: controller.sections)

        if delegate?.fetchedResultsViewModel(controller, shouldCallObserverFor: Model.self) ?? true {
            observer?(sections)
        }
    }
}
