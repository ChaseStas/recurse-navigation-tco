//
//  First.swift
//  Architecture Test
//
//  Created by Chase on 28.02.21.
//

import SwiftUI
import ComposableArchitecture

struct FirstState: Equatable {
    @Indirect(nil)
    var second: SecondState?
    
    var navigateToSecond: Bool = false
    
    var counter: Int = 0
    let id: String = String(UUID().uuidString.prefix(5))
}

indirect enum FirstAction: Equatable {
    case second(SecondAction)
    
    case navigateToSecond(Bool)
    
    case increase
}

struct FirstEnvironment: Equatable {}

let First: Reducer<FirstState, FirstAction, FirstEnvironment> =
    Reducer<FirstState, FirstAction, FirstEnvironment>.recurse { (self) in
        .combine(
            .init({ state, action, env in
                
                switch action {
                case let .second(.first(act)):
                    guard var st = state.second?.first else { break }
                    return self.run(&state.second!.first!, act, env)
                        .map{.second(.first($0))}
                    
                case let .navigateToSecond(value):
                    state.navigateToSecond = value
                    
                    if value {
                        state.second = .init()
                    }
                    
                case .increase:
                    state.counter += 1
                default: break
                }
                return .none
                
            }),
            Second.optional().pullback(state: \.second,
                                       action: /FirstAction.second,
                                       environment: {_ in SecondEnvironment()})
        )
    }

struct FirstView: View {
    let store: Store<FirstState, FirstAction>
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text("Second")
                    .font(.body)
                VStack {
                    Text("(tap counter to increase)")
                    Text("Counter: \(viewStore.counter)")
                        .onTapGesture {
                            viewStore.send(.increase)
                        }
                }
                .padding(.vertical, 20)
                
                NavigationLink("to second", destination: IfLetStore(store.scope(state: {$0.second}, action: FirstAction.second), then: { st in SecondView(store: st)}),
                               isActive: viewStore.binding(get: {$0.navigateToSecond}, send: FirstAction.navigateToSecond))
            }
            .navigationTitle(viewStore.id)
        }
    }
}

struct FirstView_Previews: PreviewProvider {
    static var previews: some View {
        FirstView(store: .init(initialState: .init(), reducer: First, environment: FirstEnvironment()))
    }
}

