//
//  SettingMainView.swift
//  PP_MyDictionary
//
//  Created by Nguyen Minh Vu on 8/13/25.
//

import SwiftUI

struct IconInfoView: View {
    var body: some View {
        ZStack {
            VStack {
                Image("cover")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .opacity(0.6)
                Text("Images are used in app were from icon-icons.com")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .opacity(0.6)

            }
            VStack(spacing: 200) {
                Text("Press and hold on a group or language to delete")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.black)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color("detailBackground"))
                            
                    )
                    .padding(.horizontal, 30)
                    .padding(.top, 150)
                Spacer()
            }
            
        }
    }
}

#Preview {
    IconInfoView()
}
