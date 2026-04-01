//
//  ResultView.swift
//  FridgeChef
//
//  Created by Shunsuke Taira on 2026/04/01.
//

import SwiftUI

struct ResultView: View {
    var image: UIImage
    var resetAction: () -> Void
    
    @State private var isAnalyzing = true
    @State private var recipeText = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(height: 250)
                .cornerRadius(12)
                .padding()
            
            if isAnalyzing {
                ProgressView("AIが食材を分析中...")
                    .padding()
            } else {
                ScrollView {
                    Text(recipeText)
                        .padding()
                }
            }
            
            Spacer()
            
            Button(action: resetAction) {
                Text("もう一度撮影する")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .onAppear {
            //一旦適当な結果画面を表示させる
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.recipeText = "【提案レシピ】\n1. 豚肉とキャベツの塩昆布炒め\n2. 冷蔵庫の残り野菜スープ\n3. にんじんと卵のシンプルチャーハン"
                self.isAnalyzing = false
            }
        }
    }
}
