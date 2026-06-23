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
            languages = savedLanguages.sorted(by: <)
        } else {
            languages = ["English"]
            userDefaults.set(languages, forKey: Key.languages)
        }
        
        if let savedLanguage = userDefaults.string(forKey: Key.selectedLanguage) {
            selectedLanguage = savedLanguage
        } else {
            selectedLanguage = languages.first ?? ""
            userDefaults.set(selectedLanguage, forKey: Key.selectedLanguage)
        }
        
        if let savedGroups = userDefaults.stringArray(forKey: selectedLanguage) {
            groups = savedGroups.sorted(by: <)
        } else {
            groups = ["Group1"]
            userDefaults.set(groups, forKey: selectedLanguage)
        }
        
        if let savedGroup = userDefaults.string(forKey: Key.selectedGroup) {
            selectedGroup = savedGroup
        } else {
            selectedGroup = groups.first ?? ""
            userDefaults.set(selectedGroup, forKey: Key.selectedGroup)
        }
        
        isLoading = false
    }
    
    func addLanguage(_ name: String) {
        guard !name.isEmpty else { return }
        languages.append(name)
    }
    
    func renameLanguage(at index: Int, to name: String) {
        guard languages.indices.contains(index) else { return }
        let currentGroups = groups
        
        isLoading = true
        languages[index] = name
        selectedLanguage = name
        groups = currentGroups
        isLoading = false
        
        saveLanguages()
        userDefaults.set(selectedLanguage, forKey: Key.selectedLanguage)
        saveGroups()
    }
    
    func deleteLanguage(at index: Int) -> String? {
        guard languages.indices.contains(index) else { return nil }
        let deletedLanguage = languages.remove(at: index)
        
        isLoading = true
        groups = []
        isLoading = false
        
        userDefaults.set(groups, forKey: deletedLanguage)
        return deletedLanguage
    }
    
    func addGroup(_ name: String) {
        guard !name.isEmpty else { return }
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
        return groups.remove(at: index)
    }
    
    func deduplicateGroups() {
        groups = Array(Set(groups))
    }
    
    func addSelectedGroupIfNeeded(_ name: String) {
        guard !name.isEmpty, !groups.contains(name) else { return }
        groups.append(name)
    }
    
    private func loadGroupsForSelectedLanguage() {
        if let savedGroups = userDefaults.stringArray(forKey: selectedLanguage) {
            groups = savedGroups.sorted(by: <)
            selectedGroup = groups.first ?? ""
        } else {
            groups = []
            selectedGroup = ""
        }
    }
    
    private func saveLanguages() {
        userDefaults.set(languages, forKey: Key.languages)
    }
    
    private func saveGroups() {
        userDefaults.set(groups, forKey: selectedLanguage)
    }
}
