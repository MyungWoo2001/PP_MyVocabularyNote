//
//  ContentView.swift
//  PP_MyDictionary
//
//  Created by Myung Woo on 8/8/25.
//

import SwiftUI
import SwiftData

struct VocabularyListView: View {
    
    @State private var showEmptyView: Bool = true
    private func checkEmptyView(language: String) {
        if vocabularies.contains(where: { $0.language == language }) {
            showEmptyView = false
        } else {
            showEmptyView = true
        }
    }
    @StateObject private var preferences = VocabularyPreferencesStore()
    
    @State private var showNewLanguage: Bool = false
    @State var newLanguage: String = ""
    private func saveLanguage() {
        preferences.addLanguage(newLanguage)
        newLanguage = ""
    }
    @State private var showNewGroup: Bool = false
    @State var newGroup: String = ""
    private func saveGroup(){
        preferences.addGroup(newGroup)
        newGroup = ""
    }
    
    @State private var showLanguageSheet: Bool = false
    @State private var showRenameLanguage: Bool = false
    @State private var showCheckDulicateLanguage: Bool = false
    private func renameLanguage(with name: String) {
        if let index = deleteIndex {
            let targetLangue = preferences.languages[index]
            let renameVocabularies = vocabularies.filter { $0.language ==  targetLangue }
            for vocab in renameVocabularies {
                vocab.language = name
            }
            preferences.renameLanguage(at: index, to: name)
            deleteIndex = nil
            do {
                try modelContext.save()
                print("rename group successfully")
            } catch {
                print("rename group error: \(error)")
            }
        }
    }
    
    @State private var deleteIndex: Int? = nil
    @State private var showCheckDeleteLanguage = false
    private func deleteLanguage() {
        if let index = deleteIndex {
            guard let deleteLanguage = preferences.deleteLanguage(at: index) else { return }
            let deleteVocabularies = vocabularies.filter { $0.language == deleteLanguage }
            for vocab in deleteVocabularies {
                modelContext.delete(vocab)
            }
            deleteIndex = nil
        }
    }
    
    @State private var showGroupSheet: Bool = false
    @State private var showRenameGroup: Bool = false
    @State private var showCheckDulicateGroup: Bool = false
    private func renameGroup(with name: String) {
        if let index = deleteIndex {
            let targetGroup = preferences.groups[index]
            let renameVocabularies = vocabularies.filter { $0.group == targetGroup && $0.language ==  preferences.selectedLanguage }
            for vocab in renameVocabularies {
                vocab.group = name
            }
            preferences.renameGroup(at: index, to: name)
            deleteIndex = nil
            do {
                try modelContext.save()
                print("rename group successfully")
            } catch {
                print("rename group error: \(error)")
            }
        }
    }
    
    @State private var showCheckDeleteGroup: Bool = false
    private func deleteGroup() {
        if let index = deleteIndex {
            guard let deleteGroup = preferences.deleteGroup(at: index) else { return }
            let deleteVocabularies = vocabularies.filter { $0.group == deleteGroup && $0.language ==  preferences.selectedLanguage }
            for vocab in deleteVocabularies {
                modelContext.delete(vocab)
            }
            deleteIndex = nil
            do {
                try modelContext.save()
                print("Delete group successfully")
            } catch {
                print("Delete group error: \(error)")
            }
        }
    }
    
    private func checkContains(_ name: String, _ list: [String]) -> Bool {
        return list.contains(name)
    }
    
    // Search bar
    @State private var searchText: String = ""
    @State private var searchResults: [Vocabulary] = []
    @State private var isSearchActive = false
    
    // Set up walkthrough
    @State private var showWalkthrough = false
    @AppStorage("hasViewedWalkthrough") var hasViewedWalkthrough: Bool = false
    
    // fetch vocabularies from database
    @Query var vocabularies: [Vocabulary]
//    var Vocabularies: [Vocabulary] = [Vocabulary(definition: "Hello", meaning: "Xin chào", group: "Group 1", note: "")]
    private func filteredItems() -> [Vocabulary] {
        let base = isSearchActive ? searchResults : vocabularies
        return base.filter { vocab in
            vocab.language == preferences.selectedLanguage &&
            vocab.group == preferences.selectedGroup
        }
    }
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var showNewVocabulary = false
    @State private var showIconInfo = false
    
    var body: some View {
        NavigationStack {
            HorizontalMenuView(options: preferences.languages, selected: $preferences.selectedLanguage, showNew: $showNewLanguage, showCheckDelete: $showLanguageSheet, deleteIndex: $deleteIndex)
            HorizontalMenuView(options: preferences.groups, selected: $preferences.selectedGroup, showNew: $showNewGroup, showCheckDelete: $showGroupSheet, deleteIndex: $deleteIndex)

            
            List{
                if showEmptyView {
                    ZStack {
                        Image("emptyview")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal, 60)
                            .padding(.vertical, 120)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                } else {
                    let listItems = isSearchActive ? searchResults: filteredItems() 
                    ForEach(listItems.indices, id: \.self) { index in
                            ZStack(alignment: .leading) {
                                NavigationLink(destination: VocabularyDetailView(vocabulary: listItems[index])){
                                    EmptyView()
                                }
                                .opacity(0)
                                VocabularyRowView(vocabulary: listItems[index])
                                    .background(Color.white)
                                    .listRowBackground(Color.clear)
                                    .background(Color(.systemGray5))
                            }
                            .frame(maxHeight: 40, alignment: .bottom)
                    }
                    .onDelete(perform: deleteRecord)
                }
            } // ListView
            .navigationTitle("Vocabulary")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .listStyle(InsetListStyle())
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.15))
            )
            .padding(.horizontal)
            .padding(.bottom)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray, lineWidth: 1)
                    .padding(.horizontal)
                    .padding(.bottom)
            )
            .alert("New Dictionary", isPresented: $showNewLanguage){
                TextField("", text: $newLanguage)
                Button("Cancel", role: .cancel) {}
                Button("Save"){
                    saveLanguage()
                }
            }
            .confirmationDialog("Menu", isPresented: $showLanguageSheet){
                Button("Rename"){showRenameLanguage.toggle()}
                Button("Delete"){showCheckDeleteLanguage.toggle()}
                Button ("Cancel", role: .cancel) {}
            } message: {
                Text("What do you want to do?")
            }
            
            .alert("Rename Dictionary?", isPresented: $showRenameLanguage){
                TextField("", text: $newGroup)
                Button("Cancel", role: .cancel) {}
                Button("Save"){
                    renameLanguage(with: newGroup)
                    newGroup = ""
                }
            } message: {
                Text("Rename dictionary will alse change its name in all vocabulary.")
            }
            .alert("Delete Dictionary??", isPresented: $showCheckDeleteLanguage, actions: {
                Button("Cancel", role: .cancel){}
                Button("Delete"){
                    deleteLanguage()
                }
                
            }, message: {
                Text("Delete dictionary will also delete all its vocabulary. Are you sure?")
            })
            
            .alert("New Group", isPresented: $showNewGroup){
                TextField("", text: $newGroup)
                Button("Cancel", role: .cancel) {}
                Button("Save"){
                    saveGroup()
                }
            }
            .confirmationDialog("Menu", isPresented: $showGroupSheet){
                Button("Rename"){showRenameGroup.toggle()}
                Button("Delete"){showCheckDeleteGroup.toggle()}
                Button ("Cancel", role: .cancel) {}
            } message: {
                Text("What do you want to do?")
            }
            
            .alert("Rename group", isPresented: $showRenameGroup){
                TextField("", text: $newGroup)
                Button("Cancel", role: .cancel) {}
                Button("Save"){
                    if(checkContains(newGroup, preferences.groups)){
                        showCheckDulicateGroup.toggle()
                    } else {
                        renameGroup(with: newGroup)
                        newGroup = ""
                    }
                }
            } message: {
                Text("Rename group will alse change its name in all vocabulary.")
            }
            .alert("Group existed!!!", isPresented: $showCheckDulicateGroup){
                Button("Save"){
                    renameGroup(with: newGroup)
                    newGroup = ""
                    preferences.deduplicateGroups()
                }
                Button("Cancel", role:.cancel){}
            } message: {
                Text("The group already exists!!! If save, the two group will be merged.")
            }
            
            
            .alert("Delete group???", isPresented: $showCheckDeleteGroup, actions: {
                Button("Cancel", role: .cancel){}
                Button("Delete"){
                    deleteGroup()
                }
                
            }, message: {
                Text("Delete group will also delete all its vocabulary. Are you sure?")
            })
            
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        self.showIconInfo.toggle()
                    }) {
                        Image(systemName: "info.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        self.showNewVocabulary.toggle()
                    }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            
        } // NavigationStack
        .tint(.primary)
        .sheet(isPresented: $showNewVocabulary) {
            VocabularyAddingView()
        }
        .sheet(isPresented: $showWalkthrough) {
            TutorialView()
        }
        .sheet(isPresented: $showIconInfo) {
            IconInfoView()
        }
        .onAppear() {
            showWalkthrough = hasViewedWalkthrough ? false : true
            preferences.load()
            checkEmptyView(language: preferences.selectedLanguage)
        }
        .onChange(of: showNewVocabulary) { oldValue, newValue in
            preferences.load()
            checkEmptyView(language: preferences.selectedLanguage)
        }
        .onChange(of: vocabularies) { oldValue, newValue in
            checkEmptyView(language: preferences.selectedLanguage)
        }
        .onChange(of: preferences.selectedLanguage){ oldValue, newValue in
            checkEmptyView(language: preferences.selectedLanguage)
        }
        .onChange(of: preferences.selectedGroup) { oldValue, newValue in
            checkEmptyView(language: preferences.selectedLanguage)
        }

        .searchable(text: $searchText,isPresented: $isSearchActive, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
        .onChange(of: searchText) { oldValue, newValue in
            let predicate = #Predicate<Vocabulary> { vocab in  vocab.definition.localizedStandardContains(newValue) || vocab.meaning.localizedStandardContains(newValue) }
  
            let descriptor = FetchDescriptor<Vocabulary>(predicate: predicate)
            if let result = try? modelContext.fetch(descriptor) {
                searchResults = result
            }
        }
        .task{
            prepareNotification()
        }
    }// View
    
    // define record delete function
    private func deleteRecord(indexSet: IndexSet) {
        let listItem = filteredItems()
        for index in indexSet {
            let itemToDelete = listItem[index]
            modelContext.delete(itemToDelete)
        }
    }
    // Notification
    private func prepareNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Practice time!"
        content.body = "Hey buddy, it's time to practice your vocabulary!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 14400, repeats: false)
        let request = UNNotificationRequest(identifier: "MyVocab.PracticeNotify", content: content, trigger: trigger)
        // Schedule the nofitication
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

#Preview {
    VocabularyListView()
}

struct VocabularyRowView: View {
    
    @Bindable var vocabulary: Vocabulary
    
    var body: some View {
        HStack(alignment: .bottom){
            Text(vocabulary.definition)
                .font(.system(size: 19, weight: .medium, design: .rounded))
                .frame(maxWidth: 250, alignment: .leading)
                .lineLimit(1)
            Text(vocabulary.meaning)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.gray)
                .frame(maxWidth: 150, alignment: .trailing)
                .lineLimit(1)
        }
    }
}

struct HorizontalMenuView: View {
    var options: [String]
    @Binding var selected: String
    @Binding var showNew: Bool
    @Binding var showCheckDelete: Bool
    @Binding var deleteIndex: Int?
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Button(action:{
                    self.showNew.toggle()
                }) {
                    Image(systemName: "plus.circle.fill")
                } // Button
                ForEach(options.indices, id: \.self) { index in
                    Button(action: {
                        selected = options[index]
                    }) {
                        Text(options[index])
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 5)
                            .background(options[index] == selected ? Color("Background") : Color.black)
                            .cornerRadius(10)
                    }
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 1.0)
                            .onEnded { _ in
                                deleteIndex = index
                                showCheckDelete.toggle()
                            }
                    )
                }
            }
        }
        .frame(height: 40)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray, lineWidth: 1)
        )
        .padding(.horizontal)
    }
}
