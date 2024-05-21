//
//  Stat.swift
//  PokemonxTCA
//
//  Created by tsuyoshi.matsumaru on 2024/05/20.
//

import Foundation

public struct Stat: Codable, Equatable {
    public let name: String
    public let url: String

    public init(name: String, url: String) {
        self.name = name
        self.url = url
    }
}

public extension Stat {
    static func mock() -> Self {
        .init(name: "hp", url: "https://pokeapi.co/api/v2/stat/1/")
    }
}
