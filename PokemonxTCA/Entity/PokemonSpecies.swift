//
//  PokemonSpecies.swift
//  PokemonxTCA
//
//  Created by tsuyoshi.matsumaru on 2024/05/20.
//

import Foundation

public struct PokemonSpecies: Codable, Equatable {
    public let names: [PokemonName]
    public let flavorTextEntries: [PokemonFravorTextEntry]

    public init(names: [PokemonName], flavorTextEntries: [PokemonFravorTextEntry]) {
        self.names = names
        self.flavorTextEntries = flavorTextEntries
    }
}

public extension PokemonSpecies {
    static func mock() -> Self {
        .init(names: [.mock()], flavorTextEntries: [.mock()])
    }
}
