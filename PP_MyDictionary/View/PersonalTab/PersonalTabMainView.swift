//
//  PersonalTabMainView.swift
//  PP_MyDictionary
//
//  Created by Myung Woo on 8/11/25.
//

import SwiftUI

struct PersonalTabMainView: View {
    
    var images: [String] = ["person", "gearshape", "creditcard", "questionmark.circle"]
    var titles: [String] = ["Profile", "Settings", "Payment", "Help"]
    
    var body: some View {
        NavigationStack {
            List {
                HStack(spacing: 20){
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 80, height: 80)
                    Text("User Profile")
                        .font(.system(.title2, design: .rounded))
                    Spacer()
                    Button(action: {
                        
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary)
                    }
                } // HStack
                Section(header: Text("ACCOUNT")) {
                    ForEach(titles.indices, id: \.self) { index in
                        HStack {
                            Image(systemName: images[index])
                                .foregroundColor(.primary)
                            Text(titles[index])
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(.systemGray))
                        }
                    }
                }
                Button(action: {
                    
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Log out")
                    }
                }
                .foregroundColor(.primary)
            }
            .listStyle(InsetGroupedListStyle())
            Spacer()
            .navigationTitle(Text("User Profile"))
        }
    }
}

#Preview {
    PersonalTabMainView()
}
