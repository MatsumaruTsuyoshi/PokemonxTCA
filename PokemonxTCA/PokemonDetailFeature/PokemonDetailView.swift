//
//  PokemonDetailView.swift
//  PokemonxTCA
//
//  Created by tsuyoshi.matsumaru on 2024/05/19.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
public struct PokemonDetail {
    @ObservableState
    public struct State: Equatable {
        let pokemon: Pokemon
        @Shared var hasPokemon: Bool
    }

    public enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case monsterBallButtonTapped
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .binding:
                return .none
            case .monsterBallButtonTapped:
                state.hasPokemon.toggle()
                return .none
            }
        }
    }
}

public struct PokemonDetailView: View {
    @Bindable var store: StoreOf<PokemonDetail>

    public init(store: StoreOf<PokemonDetail>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // ポケモンの画像
                AsyncImage(url: URL(string: store.pokemon.sprites.frontDefault!)) {
                    image in image.resizable().aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .padding(.top, 16)
                }
                placeholder: { ProgressView() }

                // ポケモンの名前と番号
                VStack {
                    Text("No.0001")
                        .font(.title)
                        .multilineTextAlignment(.center)
                    Text(store.pokemon.name)
                        .font(.title)
                        .multilineTextAlignment(.center)
                }

                // ポケモンのタイプ
                HStack {
                    Image("grass")
                        .resizable()
                        .frame(width: 30, height: 30)
                    Image("poison")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                // ステータスバー
                VStack(alignment: .leading, spacing: 8) {
                    StatusBarView(label: "HP", value: store.pokemon.stats[0].baseStat, maxValue: 255)
                    StatusBarView(label: "こうげき", value: store.pokemon.stats[1].baseStat, maxValue: 255)
                    StatusBarView(label: "ぼうぎょ", value: store.pokemon.stats[2].baseStat, maxValue: 255)
                    StatusBarView(label: "とくこう", value: store.pokemon.stats[3].baseStat, maxValue: 255)
                    StatusBarView(label: "とくぼう", value: store.pokemon.stats[4].baseStat, maxValue: 255)
                    StatusBarView(label: "すばやさ", value: store.pokemon.stats[5].baseStat, maxValue: 255)
                }
                .padding()
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .frame(maxWidth: .infinity)

                Spacer()
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.send(.monsterBallButtonTapped)
                } label: {
                    if store.hasPokemon {
                        Image(systemName: "circle.circle.fill").foregroundColor(.red)
                    } else {
                        Image(systemName: "circle")
                    }
                }
            }
        }
    }

    // カスタムビュー：ステータスバー
    struct StatusBarView: View {
        var label: String
        var value: Int
        var maxValue: Int

        var body: some View {
            HStack {
                Text(label)
                    .frame(width: 80, alignment: .leading)
                HStack(spacing: 2) {
                    ForEach(0 ..< maxValue / 16) { index in
                        Rectangle()
                            .fill(index * 16 < value ? Color.orange : Color.gray.opacity(0.3))
                            .frame(width: 10, height: 20)
                    }
                }
            }
        }
    }
}

#Preview {
    PokemonDetailView(
        store: .init(initialState: PokemonDetail.State(pokemon: .mock(id: 1), hasPokemon: Shared(false))) {
            PokemonDetail()
        })
        .padding()
}
