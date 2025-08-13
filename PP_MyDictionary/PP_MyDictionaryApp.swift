//
//  PP_MyDictionaryApp.swift
//  PP_MyDictionary
//
//  Created by Myung Woo on 8/8/25.
//

import SwiftUI

@main
struct PP_MyDictionaryApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(for: Vocabulary.self)
    }
}
