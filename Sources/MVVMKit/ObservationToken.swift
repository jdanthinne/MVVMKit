//
//  File.swift
//  
//
//  Created by Jérôme Danthinne on 15/04/2020.
//

import Foundation

public final class ObservationToken {
    private let cancellationClosure: () -> Void

    init(cancellationClosure: @escaping () -> Void) {
        self.cancellationClosure = cancellationClosure
    }

    public func cancel() {
        cancellationClosure()
    }
}
