//
//  PokemonSprites.swift
//  PokemonxTCA
//
//  Created by tsuyoshi.matsumaru on 2024/05/12.
//

import Foundation

public struct PokemonSprites: Codable, Equatable {
    public let frontDefault: String?

    public init(frontDefault: String?) {
        self.frontDefault = frontDefault
    }
}

public extension PokemonSprites {
    static func mock() -> Self {
        .init(
            frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png"
        )
    }
}
