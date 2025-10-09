//
//  PracticeTabMainView.swift
//  PP_MyDictionary
//
//  Created by Myung Woo on 8/9/25.
//

import SwiftUI
import SwiftData

struct PracticeTabMainView: View {
    
    @State private var count: Int = 0
    
    @State var languages: [String] = []
    @State var selectedLanguage: String = ""
    @State var groups: [String] = []
    @State var selectedGroup: String = ""
    
    private func loadDatas() {
        if let savedLanguages = UserDefaults.standard.stringArray(forKey: "languages") {
            languages = savedLanguages
            languages.sort(by: <)
        }
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") {
            selectedLanguage = savedLanguage
        }
        if let savedGroups = UserDefaults.standard.stringArray(forKey: selectedLanguage) {
            groups = savedGroups
            groups.sort(by: <)
        }
        if let savedGroup = UserDefaults.standard.string(forKey: "selectedGroup") {
            selectedGroup = savedGroup
        }
        words = filteredVocabularies()
        words.shuffle()
    }
    
    @State private var showNewLanguage: Bool = false
    @State var newLanguage: String = ""
    private func saveLanguage() {
        if newLanguage != "" {
            languages.append(newLanguage)
            UserDefaults.standard.set(languages, forKey: "languages")
            newLanguage = ""
        }
    }
    @State private var showNewGroup: Bool = false
    @State var newGroup: String = ""
    private func saveGroup(){
        if newGroup != "" {
            groups.append(newGroup)
            UserDefaults.standard.set(groups, forKey: selectedLanguage)
            newGroup = ""
        }
    }
    
    @Query var vocabularies: [Vocabulary]
    @State var words: [Vocabulary] = []
    private func filteredVocabularies() -> [Vocabulary] {
        return vocabularies.filter {
            $0.language == selectedLanguage && $0.group == selectedGroup
        }
    }
    
    @State var showEmptyView: Bool = true
    
    @State private var selectedIndex: Int? = nil
    private func buttonColor(for index: Int) -> Color {
        if let selected = selectedIndex {
            if selected == index {
                return index == correctIndex ? Color("wrongAnswer") : Color("rightAnswer")
            }
        }
        return Color(.systemGray6)
    }
    // Key to call view
    @State private var showVocabularyAddingView: Bool = false
    // Value for quizz
    @State private var question: Vocabulary? = nil
    @State private var answers: [String] = []
    @State private var correctIndex: Int = 0
    @State private var feedback: String? = nil
    @State private var nextQuestion: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack() {
                StoryMenuView(options: languages, selected: $selectedLanguage, key: "selectedLanguage")
                StoryMenuView(options: groups, selected: $selectedGroup, key: "selectedGroup")
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
                                    Text("What does \"\(question.definition)\" mean?")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .multilineTextAlignment(.center)
                                        .lineLimit(nil)             // Không giới hạn số dòng
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    VStack(spacing: 20) {
                                        ForEach(0..<answers.count, id: \.self) { index in
                                            Button(action: {
                                                selectedIndex = index
                                                checkAnswer(index: index)
                                            }) {
                                                Text(answers[index])
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
            generateQuestion(vocabs: filteredVocabularies())
        }
        .onChange(of: vocabularies){
            words = filteredVocabularies()
            words.shuffle()
            generateQuestion(vocabs: words)
        }
        .onChange(of: selectedGroup) {
            words = filteredVocabularies()
            words.shuffle()
            generateQuestion(vocabs: words)
            count = 0
        }
        .onChange(of: selectedLanguage){ oldValue, newValue in
            UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
            if let savedGroups = UserDefaults.standard.stringArray(forKey: selectedLanguage){
                groups = savedGroups
                groups.sort(by: <)
                selectedGroup = groups.first ?? ""
            } else {
                groups = []
                selectedGroup = ""
            }
            generateQuestion(vocabs: filteredVocabularies())
            count = 0
        }

        
    } // body
    
    func generateQuestion(vocabs: [Vocabulary]) {
        if vocabs.count >= 4 {
            showEmptyView = false
            selectedIndex = nil
            question = nil
            nextQuestion = false
            
            let num = count % vocabs.count
            
            let selectedObject = vocabs[num]
            
            var wrongOptions = vocabs
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
        } else {
            showEmptyView = true
        }
    }
    
    func checkAnswer(index: Int) {
        if index == correctIndex {
            nextQuestion = true
            count+=1
            if count % words.count == 0{
                words.shuffle()
            }
        } else {
            nextQuestion = false
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
    var key: String
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(options.indices, id: \.self) { index in
                    Button(action: {
                        selected = options[index]
                        UserDefaults.standard.set(selected, forKey: key)
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
