//
//  QuizEngine.swift
//  PP_MyDictionary
//
//  Created by Codex on 6/23/26.
//

import Foundation

struct QuizVocabularyItem: Identifiable, Equatable {
    let id: UUID
    let word: String
    let meaning: String
    
    init(id: UUID = UUID(), word: String, meaning: String) {
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
        guard canGenerateQuestion(from: vocabularies) else { return nil }
        
        let safeIndex = questionIndex % vocabularies.count
        let selectedItem = vocabularies[safeIndex]
        
        var options = vocabularies
            .filter { $0.id != selectedItem.id }
            .shuffled()
            .prefix(3)
            .map { $0.meaning }
        
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
