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
        @Shared var hasPokemon: Bool
    }

    public enum Action {
        case itemTapped
        case delegate(Delegate)

        // 役割が分かっていない
        @CasePathable
        public enum Delegate {
            case goToDetail(Pokemon, Shared<Bool>)
        }
    }

    public var body: some ReducerOf<Self> { // ここのSelfは何を指すのだろう？おそらく、State,Actionだと思うが
        Reduce { state, action in
            switch action {
            case .itemTapped:
                return .send(.delegate(.goToDetail(state.pokemon, state.$hasPokemon)))
            case .delegate:
                return .none
            }
        }
    }
}

struct PokemonListItemView: View {
    let store: StoreOf<PokemonListItem>

    var body: some View { // Viewプロトコルに準拠(https://zenn.dev/kyuko/articles/cc1f2512ee6b3f)
        Button {
            store.send(.itemTapped)
        } label: {
            VStack {
                AsyncImage(url: URL(string: store.pokemon.sprites.frontDefault!)) { // fixme ..!
                    image in image.resizable()
                }
                placeholder: {
                    ProgressView()
                }.frame(width: 140, height: 140)

                HStack {
                    if store.hasPokemon {
                        Image(systemName: "circle.circle.fill").foregroundColor(.red)
                    } else {
                        Image(systemName: "circle")
                    }

                    Text(store.pokemon.name)
                }
            }
        }
        .frame(width: 160, height: 160)
    }
}

#Preview {
    PokemonListItemView(
        store: .init(
            initialState: PokemonListItem.State(pokemon: .mock(id: 1), hasPokemon: Shared(false)))
        {
            PokemonListItem()
        }
    )
    .padding()
}
