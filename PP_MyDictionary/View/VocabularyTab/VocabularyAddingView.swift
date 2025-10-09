//
//  VocabularyAddingView.swift
//  PP_MyDictionary
//
//  Created by Myung Woo on 8/8/25.
//

import SwiftUI
import SwiftData

struct VocabularyAddingView: View {
        
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
    
    @Query var Vocabularies: [Vocabulary]
    @State private var saveVocabularies: [VocabularyDraft] = [VocabularyDraft()]
        
    @State private var showAlert: Bool = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext // call the database
        
    private func save() {
        for draf in saveVocabularies {
            if draf.definition != "" && draf.meaning != "" && draf.group != "" && selectedLanguage != "" {
                let vocabulary = Vocabulary(
                    definition: draf.definition,
                    meaning: draf.meaning,
                    group: draf.group ,
                    note: draf.note,
                    language: self.selectedLanguage
                )
                modelContext.insert(vocabulary)
            }
        } // for
        try? modelContext.save()
    } // save
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    LanguageMenuView(languages: languages, showNewLanguage: $showNewLanguage, selectedLanguage: $selectedLanguage)
                    
                    RowView(saveVocabularies: $saveVocabularies, groups: groups, selectedGroup: $selectedGroup, isPresented: $showNewGroup) // ForEach
                    AddingRowView(saveVocabularies: $saveVocabularies) // HStack2
                } // Vstack
                .padding(5)
            }
            .navigationTitle("New Vocabulary")
            .navigationBarTitleDisplayMode(.inline)
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
            .alert("Notice", isPresented: $showAlert, actions: {
                Button("Cancel", role: .cancel) {}
                Button("Save") {
                    showAlert = false
                    save()
                    dismiss()
                }
            }, message: {
                Text("Vocabulary entries without complete information will not be saved!!!")
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.primary)
                    }
                    .tint(.black)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        for draf in saveVocabularies {
                            if draf.definition == "" || draf.meaning == "" || draf.group == "" || selectedLanguage == "" {
                                showAlert = true
                            }
                        }
                        if !showAlert{
                            save()
                            dismiss()
                        }
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.primary)
                    }
                }
            } // ScrollView
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray.opacity(0.6))
            )
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color("detailBackground"))
            )
            .padding(5)
        } // Navigation
        .onAppear(){
            loadDatas()
        }
        .onChange(of: selectedLanguage){ oldValue, newValue in
            UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
            if let savedGroups = UserDefaults.standard.stringArray(forKey: selectedLanguage){
                groups = savedGroups
                selectedGroup = groups.first ?? ""
            } else {
                groups = []
                selectedGroup = ""
            }
        }
    }
}

struct FormTextField: View {
    var placeholder: String = ""
    
    @Binding var value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField(placeholder, text: $value)
                .font(.system(.body, design: .rounded))
                .textFieldStyle(PlainTextFieldStyle())
                .padding(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(.systemGray), lineWidth: 1)
                )
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(.systemGray5)))
            
        }
        .frame(height: 40)
    }
}

#Preview {
    VocabularyAddingView(selectedLanguage: "English")
}


struct AddingRowView: View {
    @Binding var saveVocabularies: [VocabularyDraft]
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                saveVocabularies.append(VocabularyDraft())
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width:32, height: 32)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
    }
}

struct RowView: View {
    @Binding var saveVocabularies: [VocabularyDraft]
    var groups: [String]
    @Binding var selectedGroup: String
    @Binding var isPresented: Bool
    var body: some View {
        ForEach(saveVocabularies.indices, id: \.self) { index in
            HStack(spacing: 5) {
                HStack {
                    FormTextField(placeholder: "New word", value: $saveVocabularies[index].definition)
                    FormTextField(placeholder: "Meaning", value: $saveVocabularies[index].meaning)
                    Menu{
                        Button("Add group"){
                            isPresented.toggle()
                        }
                        ForEach(groups, id: \.self){
                            group in
                            Button(group){
                                saveVocabularies[index].group = group
                            }
                        }
                    } label: {
                        Text(saveVocabularies[index].group == "" ? "Group" : saveVocabularies[index].group)
                            .foregroundColor(.black)
                            .font(.system(.body, design: .rounded))
                            .padding(5)
                    }
                    .frame(width: 60, height: 36)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                    )
                }
            } // HStack
            .padding(5)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 1)
            )
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
            )
        }
    }
}

struct LanguageMenuView: View {
    var languages: [String]
    @Binding var showNewLanguage: Bool
    @Binding var selectedLanguage: String
    
    var body: some View {
        Menu{
            Button("New Language"){
                showNewLanguage.toggle()
            }
            ForEach(languages, id: \.self){
                lang in
                Button(lang){
                    self.selectedLanguage = lang
                }
            }
        }label: {
            Text(selectedLanguage)
                .foregroundColor(.black)
                .font(.system(size: 18, weight: .medium))
                .padding(.horizontal,5)
                .padding(.vertical,5)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 1)
                )
        }
    }
}
