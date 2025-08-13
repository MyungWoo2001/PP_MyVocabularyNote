//
//  TutorialView.swift
//  PP_MyDictionary
//
//  Created by Myung Woo on 8/8/25.
//

import SwiftUI

struct TutorialView: View {
    
    @AppStorage("hasViewedWalkthrough") var hasViewedWalkthrough: Bool = false
    
    // Change dot color
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .systemIndigo
    }
    
    @State private var currentPage = 0
    @Environment(\.dismiss) var dismiss
    
    let pageHeadings = ["CREATE TYOUR OWN DICTIONARY", "TEST YOUR VOCABULARY", "IMPROVE YOUR LANGUAE SKILL"]
    let pageSubHeadings = ["Store new vocabulary like a dictionary to search and styding", "Practic your vocabulary by test it every time", "Improve your language skill by using your own dictionary"]
    let pageImages = ["onboarding-1", "onboarding-2", "onboarding-3"]
    
    var body: some View {
        
        VStack {
            TabView(selection: $currentPage) {
                ForEach(pageHeadings.indices, id: \.self) { index in
                    TutorialPage(image: pageImages[index], heading: pageHeadings[index], subHeading: pageSubHeadings[index])
                } // ForEach
            } // TabView
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .animation(.default, value: currentPage)
        
            VStack(spacing: 20) {
                Button(action: {
                    if currentPage < pageHeadings.count - 1 {
                        currentPage += 1
                    } else {
                        hasViewedWalkthrough = true
                        dismiss()
                    }
                }) {
                    Text(currentPage == pageHeadings.count - 1 ? "Get Started" : "Next")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                        .padding(.horizontal, 40)
                        .background(Color(.systemIndigo))
                        .cornerRadius(10)
                }
                
                if currentPage < pageHeadings.count - 1 {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Skip")
                            .font(.headline)
                            .foregroundStyle(Color(.gray))
                    } // Button
                } // if
            } // Vstack 2
            .padding(.bottom)
        } // Vstack 1
    } // body
} // Tutial

struct TutorialPage: View {
    
    let image: String
    let heading: String
    let subHeading: String
    
    var body: some View{
        VStack(spacing: 70) {
            Image(image)
                .resizable()
                .scaledToFit()
                .padding(.horizontal,80)
                .padding(.top, 50)
            
            VStack(spacing: 10) {
                Text(heading)
                    .font(.headline)
                
                Text(subHeading)
                    .font(.body)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding(.top)
    }
}

#Preview {
    TutorialView()
}
