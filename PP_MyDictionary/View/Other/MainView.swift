//
//  MainView.swift
//  PP_MyDictionary
//
//  Created by Myung Woo on 8/8/25.
//

import SwiftUI
import SwiftData

struct MainView: View {
    
    @EnvironmentObject var appState: AppState
    
    @Environment(\.modelContext) var moldelContext
    @Query var vocabularies: [Vocabulary]
    
    @State private var selectedTabIndex = 0
    @State var languages: [String] = []
    @State var selectedLanguage: String = ""
    @State var groups: [String] = []
    @State var selectedGroup: String = ""
    
    private func loadDatas() {
        if UserDefaults.standard.stringArray(forKey: "languages") == nil {
            languages = ["English"]
            UserDefaults.standard.set(languages, forKey: "languages")
        }
        if UserDefaults.standard.string(forKey: "selectedLanguage") == nil {
            selectedLanguage = languages.first ?? ""
            UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
        }
        if UserDefaults.standard.stringArray(forKey: selectedLanguage) == nil {
            groups = ["Group1"]
            UserDefaults.standard.set(groups, forKey: selectedLanguage)
        }
        if UserDefaults.standard.string(forKey: "selectedGroup") == nil {
            selectedGroup = groups.first ?? ""
            UserDefaults.standard.set(selectedGroup, forKey: "selectedGroup")
        }
        for vocab in vocabularies {
            
            if vocab.language == "" {
                vocab.language = selectedLanguage
            }
            if vocab.group == "" {
                vocab.group = selectedGroup
            }
        }
    }
        
    var body: some View {
        
        TabView(selection: $appState.tabIndex) {
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
        .tint(.primary)
        .onAppear(){
            loadDatas()
        }
    }
}

#Preview {
    MainView()
}
