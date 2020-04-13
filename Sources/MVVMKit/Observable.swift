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
    var listener: Listener?

    public var value: T {
        get {
            _value
        }
        set {
            if newValue != _value {
                _value = newValue
                listener?(_value)
            }
        }
    }

    public init(_ value: T) {
        _value = value
    }

    public func bind(listener: Listener?) {
        self.listener = listener
        listener?(_value)
    }
}
