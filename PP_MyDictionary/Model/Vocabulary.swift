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
    var correctCount: Int = 0
    var wrongCount: Int = 0
    var reviewLevel: Int = 0
    var lastReviewedAt: Date?
    var nextReviewAt: Date?
    
    
    init(definition: String, meaning: String,group: String = "Group1", note: String, language: String = "English") {
        self.definition = definition
        self.meaning = meaning
        self.group = group
        self.note = note
        self.language = language
    }
}

struct VocabularyDraft: Identifiable {
    var id = UUID()
    var definition: String = ""
    var meaning: String = ""
    var note: String = ""
    var group: String = ""
    var language: String = ""
}
