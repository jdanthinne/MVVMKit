//
//  ObservableViewModel.swift
//  Metronotes
//
//  Created by Jérôme Danthinne on 02/04/2020.
//  Copyright © 2020 Apptree. All rights reserved.
//

import Foundation

public protocol ViewModelObserver: AnyObject {
    func viewModelWillChange()
    func viewModelDidChange()
}

public extension ViewModelObserver {
    func viewModelWillChange() {}
    func viewModelDidChange() {}
}

open class ObservableViewModel {
    struct Observation {
        weak var observer: ViewModelObserver?
    }
    
    public init() {}

    var observations = [ObjectIdentifier: Observation]()

    public func addObserver(_ observer: ViewModelObserver) {
        let id = ObjectIdentifier(observer)
        observations[id] = Observation(observer: observer)

        observer.viewModelDidChange()
    }

    public func removeObserver(_ observer: ViewModelObserver) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }

    public func modelDidChange() {
        for (id, observation) in observations {
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }

            observer.viewModelDidChange()
        }
    }

    public func modelWillChange() {
        for (id, observation) in observations {
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }

            observer.viewModelWillChange()
        }
    }
}
