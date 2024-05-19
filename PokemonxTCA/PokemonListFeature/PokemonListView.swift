//
//  PokemonListView.swift
//  PokemonxTCA
//
//  Created by tsuyoshi.matsumaru on 2024/05/12.
//

import CasePaths
import ComposableArchitecture
import Dependencies
import Foundation
import SwiftUI

@Reducer
public struct PokemonList {
    @ObservableState
    public struct State: Equatable {
        var pokemonListItems: IdentifiedArrayOf<PokemonListItem.State> = []
        var isLoading: Bool = false
        var canLoadMore: Bool = true
        var index: Int = 1
        let limit: Int = 20 // 一度に取得する数
        let maxLimit: Int = 1302 // 最大数
        var path = StackState<Path.State>() // pathをstackしておくもの
        public init() {}
    }

    public enum Action: BindableAction {
        case onAppear
        case searchPokemonResponse(Result<[Pokemon], Error>)
        case pokemonListItems(IdentifiedActionOf<PokemonListItem>)
        case binding(BindingAction<State>) // BindableActionを継承すると必須、役割は？
        case loadMore
        case path(StackAction<Path.State, Path.Action>) // StackActionがあればStackにある各画面と簡単にやり取りができる
    }

    @Dependency(\.pokemonAPIClient) var pokemonAPIClient

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                let currentIndex = state.index
                let limit = state.limit

                return .run { send in
                    await send(
                        .searchPokemonResponse(
                            Result {
                                try await pokemonAPIClient.searchPokemonDetails(id: currentIndex, limit: limit)
                            }
                        )
                    )
                }
            case let .searchPokemonResponse(result):
                state.isLoading = false
                switch result {
                case let .success(pokemons):
                    state.pokemonList = state.pokemonList + .init(
                        uniqueElements: pokemons.map {
                            .init(pokemon: $0) // どこのinit?
                        }
                    )
                    state.index += state.limit
                    state.canLoadMore = state.index < state.maxLimit
                    return .none
                case .failure:
                    // error handling
                    return .none
                }
            case .loadMore:
                let currentIndex = state.index
                let limit = state.limit
                return .run { send in
                    await send(
                        .searchPokemonResponse(
                            Result {
                                try await pokemonAPIClient.searchPokemonDetails(id: currentIndex, limit: limit)
                            }
                        )
                    )
                }
            case .binding:
                return .none
            case let .pokemonListItems(.element(id, .itemTapped)):
                guard let pokemonListItem = state.pokemonListItems[id: id]?.pokemon
                else { return .none }

                state.path.append(.pokemonListItem(pokemonListItem).init(pokemon: pokemonListItem))

                return .none
            case .path:
                return .none
            }
        }
        // PokemonList ReducerとPokemonListItem Reducer接続
        // Action に指定している KeyPath は純粋な KeyPath ではなく Point-Free のライブラリである CasePath の機能を利用した CaseKeyPath というものになっています。（意味がよく分かっていない）
        .forEach(\.pokemonListItems, action: \.pokemonListItems) {
            PokemonListItem()
        }
        // PokemonList ReducerとPath Reducerを接続
        .forEach(\.path, action: \.path)
    }
}

extension PokemonList {
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Alert>)

        public enum Alert: Equatable {}
    }

    // 画面遷移用のPath
    @Reducer(state: .equatable)
    public enum Path {
        // pokemonListItemView用のpath
        case pokemonListItem(PokemonListItem)
        // 他の画面があればpathを追加していく
    }
}

public struct PokemonListView: View {
    @Bindable var store: StoreOf<PokemonList>

    public init(store: StoreOf<PokemonList>) {
        self.store = store
    }

    public var body: some View {
        // Stack-based navigation API は Collection で状態を管理する
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            Group {
                if store.isLoading {
                    ProgressView()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                            ForEach(
                                store.scope(
                                    state: \.pokemonList,
                                    action: \.pokemonList
                                ),
                                content: PokemonListItemView.init(store:)
                            )
                        }
                        if store.canLoadMore {
                            Text("Loading...")
                                .padding()
                                .onAppear {
                                    store.send(.loadMore)
                                }
                        }
                    }
                }
            }
            .navigationTitle("ポケモン図鑑")
        }
        destination: { store in
            switch store.case {
            case let .pokemonListItem(store):
                PokemonListItemView(store: store)
            }
        }

        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    PokemonListView(
        store: .init(
            initialState: PokemonList.State()
        ) {
            PokemonList()
        } withDependencies: {
            $0.pokemonAPIClient.searchPokemonDetails = { @Sendable _, _ in
                (1 ... 20).map { .mock(id: $0) }
            }
        }
    )
    .padding()
}
