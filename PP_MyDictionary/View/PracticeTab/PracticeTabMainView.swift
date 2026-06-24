//
//  PracticeTabMainView.swift
//  PP_MyDictionary
//
//  Created by Myung Woo on 8/9/25.
//

import SwiftUI
import SwiftData

enum PracticeMode: String, CaseIterable {
    case todayReview = "Today Review"
    case allWords = "All Words"
}

struct PracticeTabMainView: View {
    
    private let quizEngine = QuizEngine()
    private let reviewScheduler = ReviewScheduler()
    
    @State private var count: Int = 0
    @State private var questionIndex: Int = 0
    
    @StateObject private var preferences = VocabularyPreferencesStore()
    
    private func loadDatas() {
        preferences.load()
        refreshQuiz(resetProgress: true)
    }
    
    @Query var vocabularies: [Vocabulary]
    @Environment(\.modelContext) private var modelContext
    
    @State private var practiceMode: PracticeMode = .todayReview
    @State var words: [QuizVocabularyItem] = []
    @State private var answerPool: [QuizVocabularyItem] = []
    @State private var emptyMessage: String = "You have to add at least 4 words to start practicing!"
    
    private func filteredVocabularyModels() -> [Vocabulary] {
        vocabularies.filter {
            $0.language == preferences.selectedLanguage && $0.group == preferences.selectedGroup
        }
    }
    
    @State var showEmptyView: Bool = true
    
    @State private var selectedIndex: Int? = nil
    private func buttonColor(for index: Int) -> Color {
        guard let question, let selected = selectedIndex else {
            return Color(.systemGray6)
        }
        
        if index == question.correctIndex {
            return Color("rightAnswer")
        }
        
        if index == selected {
            return Color("wrongAnswer")
        }
        
        return Color(.systemGray6)
    }
    // Key to call view
    @State private var showVocabularyAddingView: Bool = false
    // Value for quizz
    @State private var question: QuizQuestion? = nil
    @State private var hasAnswered: Bool = false
    @State private var nextQuestion: Bool = false
    @State private var isSavingReviewResult: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack() {
                StoryMenuView(options: preferences.languages, selected: $preferences.selectedLanguage)
                StoryMenuView(options: preferences.groups, selected: $preferences.selectedGroup)
                Picker("Practice Mode", selection: $practiceMode) {
                    ForEach(PracticeMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                VStack {
                    if showEmptyView {
                        PracticeEmptyView(showVocabularyAddingView: $showVocabularyAddingView, message: emptyMessage)
                        Spacer()
                            .navigationTitle("Practice")
                    } else {
                        VStack(alignment: .trailing, spacing: 10) {
                            VStack(alignment: .trailing) {
                                Text("Count: \(count)")
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .frame(width: 100, height: 30)
                            }
                            VStack(spacing: 40) {
                                if let question = question {
                                    Text(question.questionText)
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .multilineTextAlignment(.center)
                                        .lineLimit(nil)             // Không giới hạn số dòng
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    VStack(spacing: 20) {
                                        ForEach(0..<question.options.count, id: \.self) { index in
                                            Button(action: {
                                                guard !hasAnswered else { return }
                                                selectedIndex = index
                                                checkAnswer(index: index)
                                            }) {
                                                Text(question.options[index])
                                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                                    .padding()
                                                    .frame(maxWidth: .infinity)
                                                    .background(buttonColor(for: index))
                                                    .cornerRadius(8)
                                                    .foregroundColor(.primary)
                                            }
                                        }
                                    }
                                    if (nextQuestion) {
                                        Button(action: {
                                            generateQuestion(vocabs: words, answerPool: answerPool)
                                        }) {
                                            Text("Next Question")
                                                .font(.title3)
                                                .padding()
                                        }
                                        .foregroundColor(.white)
                                        .background(Color.black)
                                        .cornerRadius(20)
                                    }
                                } // if let question...
                            } // VStack
                            .padding(.horizontal)
                            .navigationTitle("Practice")
                            .navigationBarTitleDisplayMode(.large)
                        }
                        .frame(maxHeight: .infinity, alignment: .top)
                        .padding(.vertical, 10)
                    } // else
                }// Vstack
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color("detailBackground").opacity(0.8))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.horizontal)
            }
        } // Navigation
        .sheet(isPresented: $showVocabularyAddingView){
            VocabularyAddingView()
        }
        .onAppear(){
            loadDatas()
        }
        .onChange(of: vocabularies){
            if isSavingReviewResult {
                isSavingReviewResult = false
                return
            }
            refreshQuiz(resetProgress: true)
        }
        .onChange(of: preferences.selectedGroup) {
            refreshQuiz(resetProgress: true)
        }
        .onChange(of: preferences.selectedLanguage){ oldValue, newValue in
            refreshQuiz(resetProgress: true)
        }
        .onChange(of: practiceMode) { oldValue, newValue in
            refreshQuiz(resetProgress: true)
        }

        
    } // body
    
    private func quizItems(from vocabularies: [Vocabulary]) -> [QuizVocabularyItem] {
        vocabularies.map {
            QuizVocabularyItem(id: $0.persistentModelID, word: $0.definition, meaning: $0.meaning)
        }
    }
    
    private func refreshQuiz(resetProgress: Bool) {
        let groupVocabularies = filteredVocabularyModels()
        answerPool = quizItems(from: groupVocabularies)
        
        if resetProgress {
            count = 0
            questionIndex = 0
        }
        
        guard groupVocabularies.count >= 4 else {
            words = []
            emptyMessage = "You have to add at least 4 words to start practicing!"
            generateQuestion(vocabs: words, answerPool: answerPool)
            return
        }
        
        switch practiceMode {
        case .todayReview:
            let dueVocabularies = reviewScheduler.dueVocabularies(from: groupVocabularies)
            words = quizItems(from: dueVocabularies)
            if words.isEmpty {
                emptyMessage = "You have completed today's review!"
            }
        case .allWords:
            words = answerPool
        }
        
        words.shuffle()
        generateQuestion(vocabs: words, answerPool: answerPool)
    }
    
    func generateQuestion(vocabs: [QuizVocabularyItem], answerPool: [QuizVocabularyItem]) {
        if let generatedQuestion = quizEngine.generateQuestion(from: vocabs, answerPool: answerPool, questionIndex: questionIndex) {
            showEmptyView = false
            selectedIndex = nil
            hasAnswered = false
            nextQuestion = false
            question = generatedQuestion
        } else {
            showEmptyView = true
            selectedIndex = nil
            hasAnswered = false
            question = nil
            nextQuestion = false
        }
    }
    
    func checkAnswer(index: Int) {
        guard let question, !hasAnswered else { return }
        hasAnswered = true
        nextQuestion = true
        let isCorrect = quizEngine.isCorrect(selectedIndex: index, question: question)
        
        if isCorrect {
            count+=1
        }
        
        if let reviewedVocabulary = vocabularies.first(where: { $0.persistentModelID == question.vocabulary.id }) {
            reviewScheduler.updateReviewResult(for: reviewedVocabulary, isCorrect: isCorrect)
            do {
                isSavingReviewResult = true
                try modelContext.save()
            } catch {
                isSavingReviewResult = false
                print("Save review result error: \(error)")
            }
        }
        
        if practiceMode == .todayReview && isCorrect {
            words.removeAll { $0.id == question.vocabulary.id }
            if words.isEmpty {
                emptyMessage = "You have completed today's review!"
            }
        }
        
        questionIndex += 1
        if !words.isEmpty && questionIndex % words.count == 0{
            words.shuffle()
        }
    }
} // struct

struct PickerView2: View {
    var options: [String]
    @Binding var selectedOption: String
    @State var title: String
    
    @State private var showMoreOptions: Bool = false
    
    var body: some View {
        Menu {
            ForEach(options,id: \.self) {
                option in
                Button(option){
                    selectedOption = option
                    title = option
                }
            }
        } label: {
            Text(title)
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    PracticeTabMainView()
}


struct PracticeEmptyView: View {
    @Binding var showVocabularyAddingView: Bool
    var message: String = "You have to add at least 4 words to start practicing!"
    
    var body: some View {
        VStack(spacing: 60){
            Image(systemName: "book.closed")
                .resizable()
                .frame(width: 128, height: 128)
                .padding(.horizontal, 100)
            
            Text(message)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 50)
            
            Button(action: {
                self.showVocabularyAddingView.toggle()
            }) {
                Text("New Vocabulary")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .padding()
            }
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
        } // Vstack
        .padding(.top, 80)
    }
}

struct MenuView: View {
    var options: [String]
    @Binding var selectedOption: String
    var body: some View {
        Menu{
            ForEach(options, id: \.self){
                opt in
                Button(opt){
                    selectedOption = opt
                }
            }
        } label: {
            Text(selectedOption)
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(.black)
                .padding(5)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.gray, lineWidth: 1)
        )
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(.systemGray5))
        )
    }
}

struct StoryMenuView: View {
    var options: [String]
    @Binding var selected: String
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(options.indices, id: \.self) { index in
                    Button(action: {
                        selected = options[index]
                    }) {
                        Text(options[index])
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 5)
                            .background(options[index] == selected ? Color("Background") : Color.black)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal, 5)
        }
        .frame(height: 40)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray, lineWidth: 1)
        )
        .padding(.horizontal)
    }
}
