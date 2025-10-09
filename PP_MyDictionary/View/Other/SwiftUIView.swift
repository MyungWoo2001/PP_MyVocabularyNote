//
//  SwiftUIView.swift
//  PP_MyDictionary
//
//  Created by Nguyen Minh Vu on 9/8/25.
//

import SwiftUI

struct SwiftUIView: View {
    @State private var showAlert = false
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        Button("Show Alert"){
            showAlert.toggle()
        }
        .alert("Hello", isPresented: $showAlert, actions: {
            Button("Cancel", role: .cancel){}
            Button("Delete"){
                showAlert.toggle()
            }
        }, message: {
            Text("Delete language also remove all vocabulary!!!")
        })
    }
}

#Preview {
    SwiftUIView()
}
