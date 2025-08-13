//
//  MainView.swift
//  PP_MyDictionary
//
//  Created by Myung Woo on 8/8/25.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTabIndex = 0
    
    var body: some View {
        TabView(selection: $selectedTabIndex) {
            VocabularyListView()
                .tabItem {
                    Label("Dictionary", systemImage: "book.fill")
                }
                .tag(0)
            
            PracticeTabMainView()
                .tabItem {
                    Label("Test", systemImage: "list.bullet.rectangle")
                }
                .tag(1)
        }
    }
}

#Preview {
    MainView()
}
