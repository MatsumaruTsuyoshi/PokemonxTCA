//
//  PokemonFravorTextEntry.swift
//  PokemonxTCA
//
//  Created by tsuyoshi.matsumaru on 2024/05/20.
//

import Foundation

public struct PokemonFravorTextEntry: Codable, Equatable {
    public let flavroText: String
    public let launguage: Launguage

    public init(flavroText: String, launguage: Launguage) {
        self.flavroText = flavroText
        self.launguage = launguage
    }
}

public extension PokemonFravorTextEntry {
    static func mock() -> Self {
        .init(flavroText: "生まれたときから　背中に 不思議な　タネが　植えてあって 体と　ともに　育つという。", launguage: .mock())
    }
}
