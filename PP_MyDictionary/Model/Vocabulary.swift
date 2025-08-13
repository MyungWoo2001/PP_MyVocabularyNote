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
    var tag: Int = 0
    
    init(definition: String, meaning: String, note: String, tag: Int) {
        self.definition = definition
        self.meaning = meaning
        self.note = note
        self.tag = tag
    }
}

//struct Vocabulary {
//    var defining: String
//    var meaning: String
//    
//    init(defining: String, meaning: String) {
//        self.defining = defining
//        self.meaning = meaning
//    }
//    
//    init(){
//        self.init(defining: "", meaning: "")
//    }
//}
