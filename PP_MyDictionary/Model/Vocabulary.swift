//
//  Vocabulary.swift
//  PP_MyDictionary
//
//  Created by Myung Woo on 8/8/25.
//

import Foundation
import SwiftData
import SwiftUI

@Model class Vocabulary {
    var definition: String = ""
    var meaning: String = ""
    var note: String = ""
    var group: String = ""
    var language: String = ""
    var languageCode: String = "en-US"
    
    
    init(definition: String, meaning: String,group: String = "Group1", note: String, language: String = "English", languageCode: String = "en-US") {
        self.definition = definition
        self.meaning = meaning
        self.group = group
        self.note = note
        self.language = language
        self.languageCode = languageCode
    }
}

struct VocabularyDraft: Identifiable {
    var id = UUID()
    var definition: String = ""
    var meaning: String = ""
    var note: String = ""
    var group: String = ""
    var language: String = ""
    var languageCode: String = ""
}
