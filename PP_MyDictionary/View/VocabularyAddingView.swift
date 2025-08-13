//
//  VocabularyAddingView.swift
//  PP_MyDictionary
//
//  Created by Myung Woo on 8/8/25.
//

import SwiftUI
import SwiftData

struct VocabularyAddingView: View {
    
    @Query var Vocabularies: [Vocabulary]
    @State private var saveVocabularies: [Vocabulary] = [Vocabulary(definition: "", meaning: "", note: "", tag: 1)]
    
    @Bindable private var vocabularyFormViewModel: VocabularyFormViewModel
    
    init() {
        let viewModel = VocabularyFormViewModel()
        vocabularyFormViewModel = viewModel
    }
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext // call the database
    private func save() {
        for index in saveVocabularies.indices {
            let vocabulary = Vocabulary(definition: saveVocabularies[index].definition, meaning: saveVocabularies[index].meaning, note: saveVocabularies[index].note, tag: Vocabularies.count + 1 + index)
            
            modelContext.insert(vocabulary)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(saveVocabularies.indices, id: \.self) { index in
                        HStack {
                            FormTextField(placeholder: "New word", value: $saveVocabularies[index].definition)
                            FormTextField(placeholder: "Meaning", value: $saveVocabularies[index].meaning)
                        }
                    } // Hstack1
                    HStack {
                        Spacer()
                        Button(action: {
                            self.saveVocabularies.append(Vocabulary(definition: "", meaning: "", note: "", tag: self.$saveVocabularies.wrappedValue.count + 1))
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width:32, height: 32)
                                .foregroundColor(.primary)
                        }
                        Spacer()
                    } // HStack2
                } // Vstack
                .padding()
            }
            .navigationTitle("New Vocabulary")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                    .tint(.black)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        save()
                        dismiss()
                    }) {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

struct FormTextField: View {
    var placeholder: String = ""
    
    @Binding var value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField(placeholder, text: $value)
                .font(.system(.body, design: .rounded))
                .textFieldStyle(PlainTextFieldStyle())
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
                .padding(.vertical, 10)
            
        }
    }
}

struct FormTextView: View {
    let label: String
    
    @Binding var value: String
    
    var height: CGFloat = 200.0
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label.uppercased())
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color(.darkGray))
            
            TextEditor(text: $value)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
                .padding(.top, 10)
            
        }
    }
}


#Preview {
    VocabularyAddingView()
}
