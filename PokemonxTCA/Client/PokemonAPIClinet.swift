//
//  PokemonAPIClinet.swift
//  PokemonxTCA
//
//  Created by tsuyoshi.matsumaru on 2024/05/12.
//

import Dependencies
import DependenciesMacros
import Foundation

/**
 DependenciesMacrosについて
 initやunimplementedなどのボイラープレートを省くことができる。詳しくはこちらhttps://qiita.com/takehilo/items/0b941c5f8e4625599cdb
 */

/**
 DependencyKey、TestDependencyKeyを使うことでDIできる

 */

@DependencyClient
public struct PokemonAPIClinet: Sendable {
    public var searchPokemonDetails: @Sendable (_ id: Int, _ limit: Int) async throws -> [Pokemon]
    // searchPokemonDetailsでも作る？for文回して[Pokemon]を返すとか
}

/**
 DependencyKeyプロトコルに準拠すると、liveValueが必要になる。
 */

extension PokemonAPIClinet: DependencyKey {
    public static var liveValue: PokemonAPIClinet {
        return PokemonAPIClinet(
            searchPokemonDetails: { id, limit in
                var pokemons: [Pokemon] = []
                for i in id ..< id + limit {
                    let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(i)")!
                    let request = URLRequest(url: url)
                    let (data, _) = try await URLSession.shared.data(for: request)
                    let pokemon = try jsonDecoder.decode(Pokemon.self, from: data)
                    pokemons.append(pokemon)
                }
                return pokemons
            }
        )
    }
}

private let jsonDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}()

/**
 DI用
 */

public extension DependencyValues {
    var pokemonAPIClient: PokemonAPIClinet {
        get { self[PokemonAPIClinet.self] }
        set { self[PokemonAPIClinet.self] = newValue }
    }
}

/**
 TestDependencyKeyを継承すると、previewValueが必須
 */
extension PokemonAPIClinet: TestDependencyKey {
    public static let previewValue = Self(
        searchPokemonDetails: { _, _ in [] }
    )

    public static let testValue = Self()
}
