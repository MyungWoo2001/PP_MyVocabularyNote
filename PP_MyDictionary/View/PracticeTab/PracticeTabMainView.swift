//
//  PracticeTabMainView.swift
//  PP_MyDictionary
//
//  Created by Myung Woo on 8/9/25.
//

import SwiftUI
import SwiftData

struct PracticeTabMainView: View {
    
    @Query var Vocabularies: [Vocabulary]
    
    // Key to call view
    @State private var showVocabularyAddingView: Bool = false
    // Value for quizz
    @State private var question: Vocabulary? = nil
    @State private var answers: [String] = []
    @State private var correctIndex: Int = 0
    @State private var feedback: String? = nil
    
    var body: some View {
        NavigationStack {
            if Vocabularies.isEmpty {
                VStack(spacing: 60){
                    Image(systemName: "book.closed")
                        .resizable()
                        .frame(width: 128, height: 128)
                        .padding(.horizontal, 100)
                    
                    Text("You have to add at least 4 words to use start practicing!")
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
                
                Spacer()
                .navigationTitle("Practice")
            } else {
                VStack(spacing: 30) {
                    if let question = question {
                        Text("What does \"\(question.definition)\" mean?")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                        
                        ForEach(0..<answers.count, id: \.self) { index in
                            Button(action: {
                                checkAnswer(index: index)
                            }) {
                                Text(answers[index])
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.systemGray3))
                                    .cornerRadius(8)
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        if let feedback = feedback {
                            Text(feedback)
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                        
                        Image(systemName: "book")
                            .resizable()
                            .frame(width: 96, height: 96)
                        Spacer()
                    } // if let question...
                } // VStack
                .padding()
                .padding(.top, 40)
                
                .navigationTitle("Practice")
            } // else
        } // Navigation
        .sheet(isPresented: $showVocabularyAddingView){
            VocabularyAddingView()
        }
        .onAppear(){
            if Vocabularies.count >= 4 {
                generateQuestion()
            }
        }
    } // body
    
    func generateQuestion() {
        feedback = nil
        let randomNum = Int.random(in: 1...Vocabularies.count)
        
        guard let selectedObject = Vocabularies.first(where: { $0.tag == randomNum }) else {
            return
        }
        
        var wrongOptions = Vocabularies
            .filter { $0.meaning != selectedObject.meaning }
            .shuffled()
            .prefix(3)
            .map { $0.meaning }
        
        // Thêm đáp án đúng vào mảng
        wrongOptions.append(selectedObject.meaning)
        
        // Shuffle toàn bộ để vị trí đúng là ngẫu nhiên
        answers = wrongOptions.shuffled()
        
        // Ghi nhớ vị trí đúng
        correctIndex = answers.firstIndex(of: selectedObject.meaning) ?? 0
        
        question = selectedObject
    }
    
    func checkAnswer(index: Int) {
        if index == correctIndex {
            generateQuestion()
        } else {
            feedback = "Wrong ❌"
        }
    }
} // struct

#Preview {
    PracticeTabMainView()
}

