//
//  PokemonDetailView.swift
//  PokemonxTCA
//
//  Created by tsuyoshi.matsumaru on 2024/05/19.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
public struct PokemonDetail {
    @ObservableState
    public struct State: Equatable {
        let pokemon: Pokemon

        public init(pokemon: Pokemon) {
            self.pokemon = pokemon
        }
    }

    public enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { _, action in
            switch action {
            case .onAppear:
                return .none
            case .binding:
                return .none
            }
        }
    }
}

public struct PokemonDetailView: View {
    @Bindable var store: StoreOf<PokemonDetail>

    public init(store: StoreOf<PokemonDetail>) {
        self.store = store
    }

    public var body: some View {
        Text(store.pokemon.name)
    }
}
