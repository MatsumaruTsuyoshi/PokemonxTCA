//
//  Pokemon.swift
//  PokemonxTCA
//
//  Created by tsuyoshi.matsumaru on 2024/05/19.
//
import Foundation

// public struct PokemonSearchResult: Codable {
//    public let items: [Pokemon]
// }

// Identifiableプロトコルに準拠することで、UUIDのように一意のidを持たせることができる。idがないとListで表示させる場合にエラーがでる。idがあるとSwiftUI側が識別可能になる
// CodableはJsonなどと相互変換するためのプロトコル
// Equatableはカスタムオブジェクトのインスタンスが等しいかどうか判断できるようになるプロトコル
public struct Pokemon: Identifiable, Codable, Equatable {
    public let id: Int
    public let name: String
    public let baseExperience: Int
    public let height: Int
    public let isDefault: Bool
    public let order: Int
    public let weight: Int
    public let sprites: PokemonSprites
    public let stats: [PokemonStats]

    // Public initializer
    public init(id: Int, name: String, baseExperience: Int, height: Int, isDefault: Bool, order: Int, weight: Int, sprites: PokemonSprites, stats: [PokemonStats]) {
        self.id = id
        self.name = name
        self.baseExperience = baseExperience
        self.height = height
        self.isDefault = isDefault
        self.order = order
        self.weight = weight
        self.sprites = sprites
        self.stats = stats
    }
}

public extension Pokemon {
    static func mock(id: Int) -> Self {
        .init(id: id, name: "フシギダネ", baseExperience: 0, height: 40, isDefault: true, order: 0, weight: 10, sprites: PokemonSprites.mock(), stats: (1...7).map { _ in .mock()})
    }
}
