//
//  Second.swift
//  Architecture Test
//
//  Created by Chase on 28.02.21.
//

import SwiftUI
import ComposableArchitecture

struct SecondState: Equatable {
    @Indirect(nil)
    var first: FirstState?
    var navigateToFirst: Bool = false
    
    let id: String = String(UUID().uuidString.prefix(5))
}

indirect enum SecondAction: Equatable {
    case first(FirstAction)
    case navigateToFirst(Bool)
}

struct SecondEnvironment: Equatable {}

let Second: Reducer<SecondState, SecondAction, SecondEnvironment> =
    Reducer<SecondState, SecondAction, SecondEnvironment>.recurse {
        (self) in
        .init { state, action, env in
            
            switch action {
            
            case let .first(.second(act)):
                guard state.first?.second != nil else { break }
                return self.run(&state.first!.second!, act, env)
                    .map{.first(.second($0))}
                
            case let .navigateToFirst(value):
                state.navigateToFirst = value
                
                if value {
                    state.first = .init()
                }
                
            default: break
            }
            
            return .none
        }
    }

struct SecondView: View {
    let store: Store<SecondState, SecondAction>
    var body: some View {
        WithViewStore(store) { viewStore in
            Text("Second")
                .font(.body)
            
            NavigationLink("Navigate to first screen", destination: IfLetStore(store.scope(state: {$0.first}, action: SecondAction.first), then: { st in FirstView(store: st)}),
                           isActive: viewStore.binding(get: {$0.navigateToFirst}, send: SecondAction.navigateToFirst))
                .navigationTitle(viewStore.id)
        }
    }
}

struct SecondView_Previews: PreviewProvider {
    static var previews: some View {
        SecondView(store: .init(initialState: .init(), reducer: Second, environment: SecondEnvironment()))
    }
}

