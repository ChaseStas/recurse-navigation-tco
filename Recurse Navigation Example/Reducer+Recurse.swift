//
//  Reducer+Recurse.swift
//  Recurse Navigation Example
//
//  Created by Chase on 1.03.21.
//

import Foundation
import ComposableArchitecture

extension Reducer {
    static func recurse(_ reducer: @escaping (Reducer) -> Reducer) -> Reducer {
        var `self`: Reducer!
        self = Reducer { state, action, environment in
            reducer(self).run(&state, action, environment)
        }
        return self
    }
}
