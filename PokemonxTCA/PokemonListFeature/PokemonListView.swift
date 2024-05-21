//
//  PokemonListView.swift
//  PokemonxTCA
//
//  Created by tsuyoshi.matsumaru on 2024/05/19.
//

import CasePaths
import ComposableArchitecture
import Dependencies
import Foundation
import IdentifiedCollections
import SwiftUI
import SwiftUINavigationCore

@Reducer
public struct PokemonList {
    // 画面遷移用のPath
    // なんでReducerが必要なんだろうか？
    // 画面遷移時、例えばPokemonDetailViewを実行しようとすると、引数のStoreOf<PokemonDetail>が必要で、PokemonDetailはReducerであるため？
    @Reducer(state: .equatable)
    public enum Path {
        // pokemonDetailView用のpath
        // 引数はPokemonDetail Reducer
        case pokemonDetail(PokemonDetail)
        // 他の画面があればpathを追加していく
    }

    @ObservableState
    public struct State: Equatable {
        var pokemonListItems: IdentifiedArrayOf<PokemonListItem.State> = []
        var isLoading: Bool = false
        var canLoadMore: Bool = true
        var index: Int = 1
        let limit: Int = 20 // 一度に取得する数
        let maxLimit: Int = 1302 // 最大数
        // 画面遷移用のpathをstackしておく変数
        var path = StackState<Path.State>()
    }

    public enum Action: BindableAction {
        case onAppear
        case searchPokemonResponse(Result<[Pokemon], Error>)
        case pokemonListItems(IdentifiedActionOf<PokemonListItem>)
        case binding(BindingAction<State>) // BindableActionを継承すると必須、役割は？
        case loadMore
        // StackActionOf<R: Reducer> = StackAction<R.State, R.Action>
        // StackActionOfはtypealias
        // typealiasについて（https://qiita.com/mono0926/items/1b94242d4139d1982a31）
        case path(StackActionOf<Path>)
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
                    state.pokemonListItems = state.pokemonListItems + .init(
                        uniqueElements: pokemons.map {
                            PokemonListItem.State(pokemon: $0, hasPokemon: Shared(false))
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
            // .itemTappedはPokemonListItemのAction
            case let .pokemonListItems(.element(id, .itemTapped)):
                guard let pokemonListItem = state.pokemonListItems[id: id]?.pokemon
                else { return .none }
                guard let hasPokemon = state.pokemonListItems[id: id]?.$hasPokemon // $だとShared<Bool>になる、なければBool
                else { return .none }

                // state.pathにPathを追加
                state.path.append(.pokemonDetail(.init(pokemon: pokemonListItem, hasPokemon: hasPokemon)))

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

public struct PokemonListView: View {
    @Bindable var store: StoreOf<PokemonList>

    public init(store: StoreOf<PokemonList>) {
        self.store = store
    }

    public var body: some View {
        // Stack-based navigation API は Collection で状態を管理する
        NavigationStack(
            // storeのStackStateとStackActionにフォーカスする
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
                                    state: \.pokemonListItems,
                                    action: \.pokemonListItems
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
        } destination: { store in
            // state.pathの状態が変われば、ここが動く（たぶん）
            // store.caseで全てのPathパターンを網羅できる
            switch store.case {
            case let .pokemonDetail(store):
                PokemonDetailView(store: store)
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
