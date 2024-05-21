//
//  Launguage.swift
//  PokemonxTCA
//
//  Created by tsuyoshi.matsumaru on 2024/05/20.
//

import Foundation

public struct Launguage: Codable, Equatable {
    public let name: String
    public let url: String

    public init(name: String, url: String) {
        self.name = name
        self.url = url
    }
}

public extension Launguage {
    static func mock() -> Self {
        .init(name: "ja", url: "https://pokeapi.co/api/v2/language/11/")
    }
}
