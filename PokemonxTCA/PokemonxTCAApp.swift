//
//  PokemonxTCAApp.swift
//  PokemonxTCA
//
//  Created by tsuyoshi.matsumaru on 2024/05/08.
//

import ComposableArchitecture
import SwiftUI

/***
 アプリはここから起動する
 */
@main
struct PokemonxTCAApp: App {
    var body: some Scene {
        WindowGroup {
            /***
             PokemonListViewは引数にStoreOf<PokemonList>をとる。
             StoreにはStateとReducerを渡している。
             */
            PokemonListView(store: Store(initialState: PokemonList.State()) {
                PokemonList()
            })
        }
    }
}
