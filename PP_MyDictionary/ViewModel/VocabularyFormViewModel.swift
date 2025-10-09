//
//  VocabularyFormViewModel.swift
//  PP_MyDictionary
//
//  Created by Myung Woo on 8/8/25.
//

import Foundation
import SwiftUI

@Observable class VocabularyFormViewModel {
    
    var definition: String = ""
    var meaning: String = ""
    var group: String = ""
    var note: String = ""
    
    init(vocabulary: Vocabulary? = nil) {
        if let vocabulary = vocabulary {
            self.definition = vocabulary.definition
            self.meaning = vocabulary.meaning
            self.group = vocabulary.group
            self.note = vocabulary.note
            
        }
    }
}
