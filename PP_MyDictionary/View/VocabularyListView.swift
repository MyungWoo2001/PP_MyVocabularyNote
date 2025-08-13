//
//  ContentView.swift
//  PP_MyDictionary
//
//  Created by Myung Woo on 8/8/25.
//

import SwiftUI
import SwiftData

struct VocabularyListView: View {
    
    // Search bar
    @State private var searchText: String = ""
    @State private var searchResults: [Vocabulary] = []
    @State private var isSearchActive = false
    
    // Set up walkthrough
    @State private var showWalkthrough = false
    @AppStorage("hasViewedWalkthrough") var hasViewedWalkthrough: Bool = false
    
    // fetch vocabularies from database
    @Query var Vocabularies: [Vocabulary]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showNewVocabulary = false
    
    var body: some View {
        NavigationStack {
            // Set up emptyview
            if Vocabularies.count == 0 {
                VStack {
                    Spacer()
                    Image("emptyview")
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal, 50)
                    Spacer()
                }
                .listRowSeparator(.hidden)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("Vocabulary")
                .navigationBarTitleDisplayMode(.automatic)
                .toolbar {
                    Button(action: {
                        self.showNewVocabulary.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            } else {
                let listItems = isSearchActive ? searchResults : Vocabularies
            List{
                ForEach(listItems.indices, id: \.self) { index in
                        VocabularyRowView(vocabulary: listItems[index])
                    }
                    .onDelete(perform: deleteRecord)
                }
            .navigationTitle("Vocabulary")
            .navigationBarTitleDisplayMode(.automatic)
            
            .toolbar {
                Button(action: {
                    self.showNewVocabulary.toggle()
                }) {
                    Image(systemName: "plus")
                }}
            } // ListView
            
        } // NavigationStack
        .tint(.primary)
        .sheet(isPresented: $showNewVocabulary) {
            VocabularyAddingView()
        }
        .sheet(isPresented: $showWalkthrough) {
            TutorialView()
        }
        .onAppear() {
            showWalkthrough = hasViewedWalkthrough ? false : true
        }
        .searchable(text: $searchText,isPresented: $isSearchActive, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
        .onChange(of: searchText) { oldValue, newValue in
            let predicate = #Predicate<Vocabulary> { vocab in  vocab.definition.localizedStandardContains(newValue) || vocab.meaning.localizedStandardContains(newValue) }
  
            let descriptor = FetchDescriptor<Vocabulary>(predicate: predicate)
            if let result = try? modelContext.fetch(descriptor) {
                searchResults = result
            }
            
        }
    }// View
    
    // define record delete function
    private func deleteRecord(indexSet: IndexSet) {
        for index in indexSet {
            let itemToDelete = Vocabularies[index]
            modelContext.delete(itemToDelete)
        }
    }
}

#Preview {
    VocabularyListView()
}

struct VocabularyRowView: View {
    
    @Bindable var vocabulary: Vocabulary
    
    var body: some View {
        HStack{
            Text(vocabulary.definition)
            Spacer()
            Text(vocabulary.meaning)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.gray)
        }
    }
}
