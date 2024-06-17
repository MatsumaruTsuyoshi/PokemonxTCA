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
    ///
    ///  【Navigation】
    ///  PathはStateとActionを保持したいのでReducerと定義する。
    ///   以前はStateとActionをぞれぞれ書いており冗長だったが、Reducerマクロのおかげでスッキリ（参考: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/migratingto1.8#Destination-and-path-reducers ）
    ///  handlingはNavigationStackのdestinationが持っている。
    ///  .equatbleはPokemonList StateがEquatableプロトコルに準拠しているの必要になる
    @Reducer(state: .equatable)
    public enum Path {
        /// pokemonDetailView用のpath,引数はPokemonDetail Reducer
        /// 他の画面があればpathを追加していく
        case pokemonDetail(PokemonDetail)
    }

    @ObservableState
    public struct State: Equatable {
        /// public typealias IdentifiedArrayOf<Element> = IdentifiedArray<Element.ID, Element>
        /// IdentifiedArrayOfはユニークなidをもつArray
        var pokemonListItems: IdentifiedArrayOf<PokemonListItem.State> = []
        var isLoading: Bool = false
        var isMoreLoading: Bool = false
        var canLoadMore: Bool = true
        var index: Int = 1
        let limit: Int = 20 // 一度に取得する数
        let maxLimit: Int = 1302 // 最大数
        /// 画面遷移用のpathをstackしておく変数
        var path = StackState<Path.State>()
    }

    public enum Action {
        case onAppear
        case searchPokemonResponse(Result<[Pokemon], Error>)
        case pokemonListItems(IdentifiedActionOf<PokemonListItem>)
        case loadMore
        /// StackActionOfはtypealias
        /// StackActionOf<R: Reducer> = StackAction<R.State, R.Action>
        case path(StackActionOf<Path>)
    }

    /// Dependencyは依存性の管理をするため。UnitTestやPreviewなどで役立つ。
    /// 「\ .」はkey pathを意味する。型安全にプロパティへの参照を表現する方法です。
    /// 省略せずに書くと”\DependencyValues.pokemonAPIClient”となる
    @Dependency(\.pokemonAPIClient) var pokemonAPIClient

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return searchPokemonDetails(index: state.index, state.limit)
            case let .searchPokemonResponse(result):
                state.isLoading = false
                state.isMoreLoading = false

                switch result {
                case let .success(pokemons):
                    /// contentsOfは配列の末尾にappendしていく
                    state.pokemonListItems.append(contentsOf:
                        pokemons.map {
                            PokemonListItem.State(pokemon: $0, hasPokemon: Shared(false))
                        }
                    )
                    state.index += state.limit
                    state.canLoadMore = state.index < state.maxLimit
                    return .none
                case .failure:
                    /// error handling
                    return .none
                }
            case .loadMore:
                state.isMoreLoading = true
                return searchPokemonDetails(index: state.index, state.limit)

            /// PokemonListItem ReducerのActionにdelegateを追加することで、
            /// 親Reducerであるここの実装部分で使えるActionを限定的にすることができる。
            ///  .goToDetailはPokemonListItemのDelegateActionである。
            case let .pokemonListItems(.element(id: _, action: .delegate(.goToDetail(pokemon, hasPokemon)))):

                /// state.pathにPathを追加。追加するとNavigationStackのdestinationが動く
                state.path.append(.pokemonDetail(.init(pokemon: pokemon, hasPokemon: hasPokemon)))
                return .none
            case .path:
                return .none
            case .pokemonListItems:
                return .none
            }
        }
        /// PokemonList ReducerとPokemonListItem Reducer接続
        /// これがないと.pokemonListItemsは反応しない
        .forEach(\.pokemonListItems, action: \.pokemonListItems) {
            PokemonListItem()
        }

        /// 【Navigation】
        /// PokemonList ReducerとPath Reducerを接続（NavigationStackの場合）
        .forEach(\.path, action: \.path)
    }

    /// 初期読み込みと追加読み込みを共通化している関数
    /// 省略しなければ"Effect.run"となる。非同期処理を実行し、その結果に基づいてアクションを発行する
    /// 非同期を並列で動かしたい場合はwithTaskGroup使うとよいみたい（　https://qiita.com/takehilo/items/24f930dddf20d0c82234　）
    func searchPokemonDetails(index currentIndex: Int, _ limit: Int) -> Effect<Action> {
        .run { send in
            await send(
                .searchPokemonResponse(
                    Result {
                        try await pokemonAPIClient.searchPokemonDetails(id: currentIndex, limit: limit)
                    }
                )
            )
        }
    }
}

public struct PokemonListView: View {
    @Bindable var store: StoreOf<PokemonList>

    public init(store: StoreOf<PokemonList>) {
        self.store = store
    }

    public var body: some View {
        /// Stack-based navigation API は Collection で状態を管理する
        NavigationStack(
            /// storeのStackStateとStackActionにフォーカスする
            /// pathはBindingなので$が必要
            path: $store.scope(state: \.path, action: \.path)
        ) {
            Group {
                if store.isLoading {
                    ProgressView()
                } else {
                    ScrollView {
                        VStack {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                                ForEach(
                                    /// ここはChildState,ChildActionだけの世界に絞っているイメージ
                                    store.scope(
                                        state: \.pokemonListItems,
                                        action: \.pokemonListItems
                                    )
                                ) { childStore in
                                    PokemonListItemView(store: childStore)
                                }
                            }
                            if store.canLoadMore && !store.isMoreLoading {
                                Button {
                                    store.send(.loadMore)
                                } label: {
                                    Text("追加取得")
                                }.padding()
                            }
                            if store.isMoreLoading {
                                ProgressView()
                            }
                        }
                    }
                }
            }
            .navigationTitle("ポケモン図鑑")
        } destination: { store in
            /// 【Navigation】
            /// state.pathの状態が変われば、ここが動く
            /// store.caseで全てのPathパターンを網羅できる
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
