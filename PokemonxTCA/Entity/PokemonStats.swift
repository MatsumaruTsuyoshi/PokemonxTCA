//
//  PokemonStats.swift
//  PokemonxTCA
//
//  Created by tsuyoshi.matsumaru on 2024/05/20.
//

import Foundation

public struct PokemonStats: Codable, Equatable {
    public let baseStat: Int
    public let effort: Int
    public let stat: Stat

    public init(baseStat: Int, effort: Int, stat: Stat) {
        self.baseStat = baseStat
        self.effort = effort
        self.stat = stat
    }
}

public extension PokemonStats {
    static func mock() -> Self {
        .init(baseStat: 45, effort: 0, stat: .mock())
    }
}
