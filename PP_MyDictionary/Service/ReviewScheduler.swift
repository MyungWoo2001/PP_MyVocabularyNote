//
//  ReviewScheduler.swift
//  PP_MyDictionary
//
//  Created by Codex on 6/23/26.
//

import Foundation

final class ReviewScheduler {
    func isDue(_ vocabulary: Vocabulary, now: Date = Date()) -> Bool {
        guard let nextReviewAt = vocabulary.nextReviewAt else {
            return true
        }
        
        return nextReviewAt <= now
    }
    
    func updateReviewResult(for vocabulary: Vocabulary, isCorrect: Bool, now: Date = Date()) {
        if isCorrect {
            vocabulary.correctCount += 1
            vocabulary.reviewLevel += 1
            vocabulary.lastReviewedAt = now
            vocabulary.nextReviewAt = nextReviewDate(for: vocabulary.reviewLevel, now: now)
        } else {
            vocabulary.wrongCount += 1
            vocabulary.reviewLevel = max(0, vocabulary.reviewLevel - 1)
            vocabulary.nextReviewAt = now
        }
    }
    
    func dueVocabularies(from vocabularies: [Vocabulary], now: Date = Date()) -> [Vocabulary] {
        vocabularies.filter { isDue($0, now: now) }
    }
    
    private func nextReviewDate(for reviewLevel: Int, now: Date) -> Date {
        let days: Int
        
        switch reviewLevel {
        case 1:
            days = 1
        case 2:
            days = 3
        case 3:
            days = 7
        default:
            days = 14
        }
        
        return Calendar.current.date(byAdding: .day, value: days, to: now) ?? now
    }
}
