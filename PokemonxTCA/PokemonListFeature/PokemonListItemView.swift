//
//  PokemonListItemView.swift
//  PokemonxTCA
//
//  Created by tsuyoshi.matsumaru on 2024/05/19.
//


import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
public struct PokemonListItem {
    // テストでStateの変化をassertionできるようにEquatableにしておく。
    @ObservableState
    public struct State: Equatable, Identifiable {
        public var id: Int { pokemon.id }
        let pokemon: Pokemon
    }

    public enum Action {
        case itemTapped
    }

    public var body: some ReducerOf<Self> { // ここのSelfは何を指すのだろう？おそらく、State,Actionだと思うが
        Reduce { _, action in
            switch action {
            case .itemTapped:
                return .none
            }
        }
    }
}

struct PokemonListItemView: View {
    let store: StoreOf<PokemonListItem>

    var body: some View { // what is some?
        Button {
            store.send(.itemTapped)
        } label: {
            VStack {
                AsyncImage(url: URL(string: store.pokemon.sprites.frontDefault!)) { // fixme ..!
                    image in image.resizable()
                }
                placeholder: { ProgressView() }

                Text(store.pokemon.name)
            }
        }
    }
}

#Preview {
    PokemonListItemView(
        store: .init(
            initialState: PokemonListItem.State(pokemon: .mock(id: 1)))
        {
            PokemonListItem()
        }
    )
    .padding()
}
