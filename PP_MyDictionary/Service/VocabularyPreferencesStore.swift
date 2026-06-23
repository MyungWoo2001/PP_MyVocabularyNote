//
//  VocabularyPreferencesStore.swift
//  PP_MyDictionary
//
//  Created by Codex on 6/23/26.
//

import Combine
import Foundation

final class VocabularyPreferencesStore: ObservableObject {
    private enum Key {
        static let languages = "languages"
        static let selectedLanguage = "selectedLanguage"
        static let selectedGroup = "selectedGroup"
    }
    
    private let userDefaults: UserDefaults
    private var isLoading = false
    
    @Published var languages: [String] = [] {
        didSet {
            guard !isLoading else { return }
            saveLanguages()
        }
    }
    
    @Published var selectedLanguage: String = "" {
        didSet {
            guard !isLoading, oldValue != selectedLanguage else { return }
            userDefaults.set(selectedLanguage, forKey: Key.selectedLanguage)
            loadGroupsForSelectedLanguage()
        }
    }
    
    @Published var groups: [String] = [] {
        didSet {
            guard !isLoading else { return }
            saveGroups()
        }
    }
    
    @Published var selectedGroup: String = "" {
        didSet {
            guard !isLoading, oldValue != selectedGroup else { return }
            userDefaults.set(selectedGroup, forKey: Key.selectedGroup)
        }
    }
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        load()
    }
    
    func load() {
        isLoading = true
        
        if let savedLanguages = userDefaults.stringArray(forKey: Key.languages) {
            languages = unique(savedLanguages).sorted(by: <)
            userDefaults.set(languages, forKey: Key.languages)
        } else {
            languages = ["English"]
            userDefaults.set(languages, forKey: Key.languages)
        }
        
        if let savedLanguage = userDefaults.string(forKey: Key.selectedLanguage),
           languages.contains(savedLanguage) {
            selectedLanguage = savedLanguage
        } else {
            selectedLanguage = languages.first ?? ""
            userDefaults.set(selectedLanguage, forKey: Key.selectedLanguage)
        }
        
        if let savedGroups = userDefaults.stringArray(forKey: selectedLanguage), !selectedLanguage.isEmpty {
            groups = unique(savedGroups).sorted(by: <)
            userDefaults.set(groups, forKey: selectedLanguage)
        } else {
            groups = selectedLanguage.isEmpty ? [] : ["Group1"]
            if !selectedLanguage.isEmpty {
                userDefaults.set(groups, forKey: selectedLanguage)
            }
        }
        
        if let savedGroup = userDefaults.string(forKey: Key.selectedGroup),
           groups.contains(savedGroup) {
            selectedGroup = savedGroup
        } else {
            selectedGroup = groups.first ?? ""
            userDefaults.set(selectedGroup, forKey: Key.selectedGroup)
        }
        
        isLoading = false
    }
    
    func addLanguage(_ name: String) {
        guard !name.isEmpty else { return }
        guard !languages.contains(name) else { return }
        languages.append(name)
    }
    
    func renameLanguage(at index: Int, to name: String) {
        guard languages.indices.contains(index), !name.isEmpty else { return }
        let oldLanguage = languages[index]
        guard oldLanguage != name else { return }
        let oldGroups = userDefaults.stringArray(forKey: oldLanguage) ?? (oldLanguage == selectedLanguage ? groups : [])
        
        isLoading = true
        if let existingIndex = languages.firstIndex(of: name), existingIndex != index {
            languages.remove(at: index)
        } else {
            languages[index] = name
        }
        
        if selectedLanguage == oldLanguage {
            selectedLanguage = name
        }
        isLoading = false
        
        saveLanguages()
        userDefaults.set(selectedLanguage, forKey: Key.selectedLanguage)
        
        let existingGroups = userDefaults.stringArray(forKey: name) ?? []
        userDefaults.set(unique(existingGroups + oldGroups).sorted(by: <), forKey: name)
        userDefaults.removeObject(forKey: oldLanguage)
        loadGroupsForSelectedLanguage()
    }
    
    func deleteLanguage(at index: Int) -> String? {
        guard languages.indices.contains(index) else { return nil }
        let wasSelectedLanguageDeleted = languages[index] == selectedLanguage
        let deletedLanguage = languages.remove(at: index)
        userDefaults.removeObject(forKey: deletedLanguage)
        
        if wasSelectedLanguageDeleted || !languages.contains(selectedLanguage) {
            selectedLanguage = languages.first ?? ""
        } else {
            loadGroupsForSelectedLanguage()
        }
        
        return deletedLanguage
    }
    
    func addGroup(_ name: String) {
        guard !name.isEmpty else { return }
        guard !groups.contains(name) else { return }
        groups.append(name)
        groups.sort(by: <)
    }
    
    func renameGroup(at index: Int, to name: String) {
        guard groups.indices.contains(index) else { return }
        groups[index] = name
        selectedGroup = name
    }
    
    func deleteGroup(at index: Int) -> String? {
        guard groups.indices.contains(index) else { return nil }
        let deletedGroup = groups.remove(at: index)
        if selectedGroup == deletedGroup || !groups.contains(selectedGroup) {
            selectedGroup = groups.first ?? ""
        }
        return deletedGroup
    }
    
    func deduplicateGroups() {
        groups = Array(Set(groups))
    }
    
    func addSelectedGroupIfNeeded(_ name: String) {
        guard !name.isEmpty, !groups.contains(name) else { return }
        groups.append(name)
    }
    
    private func loadGroupsForSelectedLanguage() {
        if let savedGroups = userDefaults.stringArray(forKey: selectedLanguage), !selectedLanguage.isEmpty {
            groups = unique(savedGroups).sorted(by: <)
        } else {
            groups = []
        }
        
        if groups.contains(selectedGroup) {
            userDefaults.set(selectedGroup, forKey: Key.selectedGroup)
        } else {
            selectedGroup = groups.first ?? ""
        }
    }
    
    private func saveLanguages() {
        userDefaults.set(languages, forKey: Key.languages)
    }
    
    private func saveGroups() {
        guard !selectedLanguage.isEmpty else { return }
        userDefaults.set(groups, forKey: selectedLanguage)
    }
    
    private func unique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values.filter { seen.insert($0).inserted }
    }
}
