//
//  DetailEditView.swift
//  PP_MyDictionary
//
//  Created by Nguyen Minh Vu on 8/30/25.
//

import SwiftUI
import SwiftData

struct DetailEditView: View {
    
    // Vocabulary
    var vocabulary: Vocabulary
    @State private var editVocabulary: VocabularyDraft = VocabularyDraft()
    
    // Language
    @State var languages: [String] = []
    @State var selectedLanguage: String = ""
    @State var groups: [String] = []
    @State var selectedGroup: String = ""
    
    private func loadDatas() {
        if let savedLanguages = UserDefaults.standard.stringArray(forKey: "languages") {
            languages = savedLanguages
            languages.sort(by: <)
        }
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") {
            selectedLanguage = savedLanguage
        }
        if let savedGroups = UserDefaults.standard.stringArray(forKey: selectedLanguage) {
            groups = savedGroups
            groups.sort(by: <)
        }
        if let savedGroup = UserDefaults.standard.string(forKey: "selectedGroup") {
            selectedGroup = savedGroup
        }
    }
    
    @State private var showNewLanguage: Bool = false
    @State var newLanguage: String = ""
    private func saveLanguage() {
        if newLanguage != "" {
            languages.append(newLanguage)
            UserDefaults.standard.set(languages, forKey: "languages")
            newLanguage = ""
        }
    }
    @State private var showNewGroup: Bool = false
    @State var newGroup: String = ""
    private func saveGroup(){
        if newGroup != "" {
            groups.append(newGroup)
            groups.sort(by: <)
            UserDefaults.standard.set(groups, forKey: selectedLanguage)
            newGroup = ""
        }
    }
    
    @State private var showDeleteGroupAlert: Bool = false
    private func deleteIfEmply(group: String){
        let descriptor = FetchDescriptor<Vocabulary>(
            predicate: #Predicate{ $0.group == group}
        )
        if let _ = try? modelContext.fetch(descriptor).first {
            showDeleteGroupAlert.toggle()
        } else {
            if let index = groups.firstIndex(of: group) {
                groups.remove(at: index)
            }
        }
    }
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    private func save(){
        if !groups.contains(editVocabulary.group) {
            groups.append(editVocabulary.group)
            UserDefaults.standard.set(groups, forKey: selectedLanguage)
        }
        if (!editVocabulary.definition.isEmpty && !editVocabulary.meaning.isEmpty){
            vocabulary.definition = editVocabulary.definition
            vocabulary.meaning = editVocabulary.meaning
            vocabulary.note = editVocabulary.note
            vocabulary.group = editVocabulary.group
            vocabulary.language = selectedLanguage
            do{
                try modelContext.save()
                print("Save success")
            } catch {
                print("Save error: \(error)")
            }
        }
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Menu {
                            Button("New Language"){
                                newLanguage = ""
                                showNewLanguage.toggle()
                            }
                            ForEach (languages, id: \.self) {
                                lang in
                                Button(lang){
                                    selectedLanguage = lang
                                }
                            }
                        } label: {
                            Text(selectedLanguage)
                                .foregroundColor(.primary)
                                .font(.system(size: 20, weight: .bold))
                                .padding(5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.8))
                                )
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.systemGray3))
                                )
                        }
                    // Label - Menu
                        
                        Menu {
                            Button("New Group"){
                                newGroup = ""
                                showNewGroup.toggle()
                            }
                            ForEach (groups, id: \.self) {
                                group in
                                Button(action: {
                                    editVocabulary.group = group
                                }) {
                                    Text(group)
                                }
                            }
                        } label: {
                            Text(editVocabulary.group == "" ? "Group" : editVocabulary.group)
                                .foregroundColor(.primary)
                                .font(.system(size: 19, weight: .bold))
                                .padding(5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.8))
                                )
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.systemGray3))
                                )
                        } // Label - Menu2
                    }

                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("Definition")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                        }
                        FormTextField(placeholder: vocabulary.definition, value: $editVocabulary.definition)
                    } // Vstack
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Meaning")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        FormTextField( placeholder: vocabulary.meaning, value: $editVocabulary.meaning)
                    } // Vstack
                    VStack(alignment: .leading, spacing: 0) {
                        Text("NOTE")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        FormTextView(label: "Write down some notes to describe your words in more detail!", value: $editVocabulary.note, height: 300)
                    } // Vstack
                } // Vstack
                .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .topLeading)
                .padding(.top, 20)
                .padding(.horizontal, 20)
            } // ScrollView
            .navigationBarBackButtonHidden(true)
            .navigationTitle("Vocabulary")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitleDisplayMode(.inline)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray.opacity(0.6))
            )
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color("detailBackground"))
            )
            .padding(5)            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action: {
                        save()
                        dismiss()
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.primary)
                    }
                    .padding(.trailing, 10)
                }
            } // Toolbar
            .alert("New Language", isPresented: $showNewLanguage){
                TextField("", text: $newLanguage)
                Button("Cancel", role: .cancel){}
                Button("Save"){
                    saveLanguage()
                }
            }
            
            .alert("New Group", isPresented: $showNewGroup){
                TextField("", text: $newGroup)
                Button("Cancel", role: .cancel){}
                Button("Save"){
                    saveGroup()
                }
            }
        }// NavigationStack
        .onAppear(){
            loadDatas()
            editVocabulary.definition = vocabulary.definition
            editVocabulary.meaning = vocabulary.meaning
            editVocabulary.note = vocabulary.note
            editVocabulary.group = vocabulary.group
            editVocabulary.language = vocabulary.language
        }
        .onChange(of: selectedLanguage){ oldValue, newValue in
            UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
            if let savedGroups = UserDefaults.standard.stringArray(forKey: selectedLanguage){
                groups = savedGroups
                groups.sort(by: <)
                selectedGroup = groups.first ?? ""
            } else {
                groups = []
                selectedGroup = ""
            }
        }
    }
}

struct FormTextView: View {
    let label: String
    
    @Binding var value: String
    
    var height: CGFloat = 200.0
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label.uppercased())
                .font(.system(size: 10, design: .rounded))
                .foregroundStyle(Color(.darkGray))
            
            TextEditor(text: $value)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(.systemGray2), lineWidth: 1)
                )
                .scrollContentBackground(.hidden)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(.systemGray5))
                )
                .padding(.top, 10)
        }
    }
}

#Preview {
    DetailEditView(vocabulary: Vocabulary(definition: "Hello", meaning: "Xin chào",group:"", note: "HELLO", language: "English"))
}
