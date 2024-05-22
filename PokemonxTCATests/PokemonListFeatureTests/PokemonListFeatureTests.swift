//
//  PokemonListFeatureTests.swift
//  PokemonxTCATests
//
//  Created by tsuyoshi.matsumaru on 2024/05/22.
//

import ComposableArchitecture
import SwiftUI
import XCTest

@testable import PokemonxTCA

final class PokemonListFeatureTests: XCTestCase {
    @MainActor
    func testPokemonListView_onAppear_loadsInitialPokemons() async {
        // responseの型明記すれば.mock = Pokemon.mockと判定してくれる
        let response: [Pokemon] = (1 ... 20).map { .mock(id: $0) }

        let store = TestStore(
            initialState: PokemonList.State())
        {
            PokemonList()
        } withDependencies: {
            $0.pokemonAPIClient.searchPokemonDetails = { @Sendable _, _ in response }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
        }

        await store.receive(\.searchPokemonResponse) {
            $0.isLoading = false
            $0.pokemonListItems = .init(
                uniqueElements: response.map {
                    .init(pokemon: $0, hasPokemon: Shared(false))
                }
            )
            $0.index = $0.index + $0.limit
            $0.canLoadMore = $0.index < $0.maxLimit
        }
    }

    @MainActor
    func testPokemonListView_loadMore_loadsAdditionalPokemons() async {
        // Setup initial state with some pokemons already loaded
        let initialPokemons: [Pokemon] = (1 ... 20).map { .mock(id: $0) }
        let additionalPokemons: [Pokemon] = (21 ... 40).map { .mock(id: $0) }
        let firstLoadMoreIndex = 21

        let store = TestStore(
            initialState: PokemonList.State(
                pokemonListItems: .init(
                    uniqueElements: initialPokemons.map {
                        .init(pokemon: $0, hasPokemon: Shared(false))
                    }
                ),
                index: firstLoadMoreIndex
            )
        ) {
            PokemonList()
        } withDependencies: {
            $0.pokemonAPIClient.searchPokemonDetails = { @Sendable firstLoadMoreIndex, _ in additionalPokemons }
        }

        // Simulate user action to load more pokemons
        await store.send(.loadMore) {
            $0.isMoreLoading = true
        }

        // Expect the state to update with additional pokemons
        await store.receive(\.searchPokemonResponse) {
            $0.isMoreLoading = false
            $0.pokemonListItems.append(contentsOf: additionalPokemons.map { .init(pokemon: $0, hasPokemon: Shared(false)) })
            $0.index = $0.index + $0.limit
            $0.canLoadMore = $0.index < $0.maxLimit
        }
    }

    @MainActor
    func testPokemonItemTapped() async {
        let store = TestStore(
            initialState: PokemonList.State(
                pokemonListItems: .init(
                    uniqueElements: [.init(pokemon: .mock(id: 1), hasPokemon: Shared(false))]
                )
            )
        ) {
            PokemonList()
        }

        // pokemonListItems[id: 1]はpokemonListItemsのPokemonクラスのプロパティのidのこと
        await store.send(\.pokemonListItems[id: 1].delegate.itemTapped) {
            $0.path = .init(
                [
                    .pokemonDetail(.init(pokemon: .mock(id: 1), hasPokemon: Shared(false))),
                ]
            )
        }
    }
}
