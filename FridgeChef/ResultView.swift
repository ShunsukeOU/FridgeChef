//
//  ResultView.swift
//  FridgeChef
//
//  Created by Shunsuke Taira on 2026/04/01.
//

import SwiftUI

struct ResultView: View {
    var image: UIImage
    var mode: DietaryMode//選択されたモードを受け取る変数を追加
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
                    //GeminiAPIを呼び出す→GeminiService.swift
                    let service = GeminiService()
                    service.analyzeImage(image: image, mode: mode) { resultText in
                        if let resultText = resultText {
                            //APIが返した文章を画面に表示する
                            self.recipeText = resultText
                        } else {
                            self.recipeText = "エラーが発生しました。もう一度撮影してください。"
                        }
                        self.isAnalyzing = false
                    }
                }
    }
}
