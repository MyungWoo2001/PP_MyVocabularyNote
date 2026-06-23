//
//  VocabularyDetailView.swift
//  PP_MyDictionary
//
//  Created by Nguyen Minh Vu on 8/27/25.
//

import SwiftUI

struct VocabularyDetailView: View {
    
    let speech = SpeechService()
    
    var vocabulary: Vocabulary
    
    @State private var showEditView: Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(vocabulary.definition)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                            
                            Spacer()
                            
                            Button(action: {
                                speech.speak(vocabulary.definition)
                            }) {
                                Image(systemName: "speaker.wave.2")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        Text(vocabulary.meaning)
                            .font(.system(size: 28, weight: .medium, design: .rounded))
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.systemGray6))
                    )
                    
                    ScrollView {
                        Text(vocabulary.note)
                            .font(.system(size: 20, weight: .regular, design: .rounded))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .padding(15)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.systemGray6))
                    )
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 20)
                
            } // ScrollView
            .navigationBarBackButtonHidden(true)
            .navigationTitle("Vocabulary Detail")
            .navigationBarTitleDisplayMode(.large)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray.opacity(0.6))
            )
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color("detailBackground"))
            )
            .padding(5)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    Button(action: {
                        dismiss()
                    }) {
                        Text("\(Image(systemName: "arrow.left")) \(vocabulary.definition)")
                            .font(.system(size: 24))
                    }
                    .foregroundColor(.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action: {
                        showEditView.toggle()
                    }) {
                        Text("\(Image(systemName: "pencil.circle"))")
                    }
                    .foregroundColor(.primary)
                }
            } // Toolbar
        } // NavigationStack
        .sheet(isPresented: $showEditView){
            DetailEditView(vocabulary: vocabulary)
        }
    }
}

#Preview {
    VocabularyDetailView(vocabulary: Vocabulary(definition: "Hello", meaning: "Xin Chào",group: "group 1", note: "Hello Everyone! This is my first app"))
}
