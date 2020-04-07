//
//  Box.swift
//  Metronotes
//
//  Created by Jérôme Danthinne on 21/03/2020.
//  Copyright © 2020 Apptree. All rights reserved.
//

import Foundation

public final class Observable<T> {
    private var _value: T

    typealias Listener = (T) -> Void
    var listener: Listener?

    var value: T {
        get {
            _value
        }
        set {
            _value = newValue
            listener?(_value)
        }
    }

    init(_ value: T) {
        _value = value
    }

    func bind(listener: Listener?) {
        self.listener = listener
        listener?(_value)
    }
}
