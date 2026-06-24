//
//  QuizEngine.swift
//  PP_MyDictionary
//
//  Created by Codex on 6/23/26.
//

import Foundation
import SwiftData

struct QuizVocabularyItem: Identifiable, Equatable {
    let id: PersistentIdentifier
    let word: String
    let meaning: String
    
    init(id: PersistentIdentifier, word: String, meaning: String) {
        self.id = id
        self.word = word
        self.meaning = meaning
    }
}

struct QuizQuestion {
    let vocabulary: QuizVocabularyItem
    let questionText: String
    let correctAnswer: String
    let options: [String]
    let correctIndex: Int
}

final class QuizEngine {
    func canGenerateQuestion(from vocabularies: [QuizVocabularyItem]) -> Bool {
        vocabularies.count >= 4
    }
    
    func generateQuestion(from vocabularies: [QuizVocabularyItem], questionIndex: Int) -> QuizQuestion? {
        generateQuestion(from: vocabularies, answerPool: vocabularies, questionIndex: questionIndex)
    }
    
    func generateQuestion(from vocabularies: [QuizVocabularyItem], answerPool: [QuizVocabularyItem], questionIndex: Int) -> QuizQuestion? {
        guard !vocabularies.isEmpty, canGenerateQuestion(from: answerPool) else { return nil }
        
        let safeIndex = questionIndex % vocabularies.count
        let selectedItem = vocabularies[safeIndex]
        
        var options = answerPool
            .filter { $0.id != selectedItem.id }
            .shuffled()
            .prefix(3)
            .map { $0.meaning }
        
        guard options.count == 3 else { return nil }
        
        options.append(selectedItem.meaning)
        let shuffledOptions = options.shuffled()
        let correctIndex = shuffledOptions.firstIndex(of: selectedItem.meaning) ?? 0
        
        return QuizQuestion(
            vocabulary: selectedItem,
            questionText: "What does \"\(selectedItem.word)\" mean?",
            correctAnswer: selectedItem.meaning,
            options: shuffledOptions,
            correctIndex: correctIndex
        )
    }
    
    func isCorrect(selectedIndex: Int, question: QuizQuestion) -> Bool {
        selectedIndex == question.correctIndex
    }
}
