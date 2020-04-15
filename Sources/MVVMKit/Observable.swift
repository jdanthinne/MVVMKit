//
//  Box.swift
//  Metronotes
//
//  Created by Jérôme Danthinne on 21/03/2020.
//  Copyright © 2020 Apptree. All rights reserved.
//

import Foundation

public final class Observable<T: Equatable> {
    private var _value: T

    public typealias Listener = (T) -> Void
    var listeners = [UUID: Listener?]()

    public var value: T {
        get {
            _value
        }
        set {
            if newValue != _value {
                _value = newValue
                for (token, listener) in listeners {
                    guard let listener = listener else {
                        listeners.removeValue(forKey: token)
                        continue
                    }

                    listener(_value)
                }
            }
        }
    }

    public init(_ value: T) {
        _value = value
    }

    public func bind(listener: Listener?) -> ObservationToken {
        let token = UUID()
        listeners[token] = listener
        listener?(_value)

        return ObservationToken { [weak self] in
            self?.listeners.removeValue(forKey: token)
        }
    }
}
