//
//  PokemonAPIClient.swift
//  PokemonxTCA
//
//  Created by tsuyoshi.matsumaru on 2024/05/19.
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

/// DependenciesMacrosの"@DependencyClient"を使うことで、ボイラープレートを大幅に削減できる
///  参考：https://qiita.com/takehilo/items/0b941c5f8e4625599cdb
///
/// Sendableとはデータ競合が発生せず安全に渡せるデータであることを表す
/// 
/// 参考：https://qiita.com/takehilo/items/39a3d4b14f7e1555e8c9
@DependencyClient
public struct PokemonAPIClinet: Sendable {
    public var searchPokemonDetails: @Sendable (_ id: Int, _ limit: Int) async throws -> [Pokemon]
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



/**
 DI用
 */
/// コメントを
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


private let jsonDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}()
