//
//  PracticeTabMainView.swift
//  PP_MyDictionary
//
//  Created by Myung Woo on 8/9/25.
//

import SwiftUI
import SwiftData

struct PracticeTabMainView: View {
    
    private let quizEngine = QuizEngine()
    
    @State private var count: Int = 0
    @State private var questionIndex: Int = 0
    
    @StateObject private var preferences = VocabularyPreferencesStore()
    
    private func loadDatas() {
        preferences.load()
        words = filteredVocabularies()
        words.shuffle()
    }
    
    @Query var vocabularies: [Vocabulary]
    @State var words: [QuizVocabularyItem] = []
    private func filteredVocabularies() -> [QuizVocabularyItem] {
        return vocabularies.filter {
            $0.language == preferences.selectedLanguage && $0.group == preferences.selectedGroup
        }.map {
            QuizVocabularyItem(word: $0.definition, meaning: $0.meaning)
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
    
    var body: some View {
        NavigationStack {
            VStack() {
                StoryMenuView(options: preferences.languages, selected: $preferences.selectedLanguage)
                StoryMenuView(options: preferences.groups, selected: $preferences.selectedGroup)
                VStack {
                    if showEmptyView {
                        PracticeEmptyView(showVocabularyAddingView: $showVocabularyAddingView)
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
                                            generateQuestion(vocabs: words)
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
            generateQuestion(vocabs: words)
        }
        .onChange(of: vocabularies){
            words = filteredVocabularies()
            words.shuffle()
            generateQuestion(vocabs: words)
        }
        .onChange(of: preferences.selectedGroup) {
            words = filteredVocabularies()
            words.shuffle()
            count = 0
            questionIndex = 0
            generateQuestion(vocabs: words)
        }
        .onChange(of: preferences.selectedLanguage){ oldValue, newValue in
            words = filteredVocabularies()
            words.shuffle()
            count = 0
            questionIndex = 0
            generateQuestion(vocabs: words)
        }

        
    } // body
    
    func generateQuestion(vocabs: [QuizVocabularyItem]) {
        if let generatedQuestion = quizEngine.generateQuestion(from: vocabs, questionIndex: questionIndex) {
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
        
        if quizEngine.isCorrect(selectedIndex: index, question: question) {
            count+=1
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
    var body: some View {
        VStack(spacing: 60){
            Image(systemName: "book.closed")
                .resizable()
                .frame(width: 128, height: 128)
                .padding(.horizontal, 100)
            
            Text("You have to add at least 4 words to start practicing!")
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
