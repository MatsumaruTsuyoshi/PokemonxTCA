//
//  PokemonName.swift
//  PokemonxTCA
//
//  Created by tsuyoshi.matsumaru on 2024/05/20.
//

import Foundation

public struct PokemonName: Codable, Equatable {
    public let launguage: Launguage
    public let name: String

    public init(launguage: Launguage, name: String) {
        self.launguage = launguage
        self.name = name
    }
}

public extension PokemonName {
    static func mock() -> Self {
        .init(launguage: .mock(), name: "フシギダネ")
    }
}
