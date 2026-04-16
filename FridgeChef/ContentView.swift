//
//  ContentView.swift
//  FridgeChef
//
//  Created by Shunsuke Taira on 2026/04/01.
//

import SwiftUI

//VeganモードとCarnivoreモードを追加
enum DietaryMode: String, CaseIterable {
    case normal = "Normal"
    case carnivore = "Carnivore"
    case vegan = "Vegan"
    
    //各モード専用の追加プロンプト
    var additionalPrompt: String {
        switch self {
        case .normal:
            return ""
        case .carnivore:
            return "【重要】今回は「Carnivore（完全肉食）モード」です。写真に写っている動物性食品（肉、魚、卵など）のみを使用し、野菜などの植物性食品は無視してください。調理油や調味料にも植物性のものは一切使わず、牛脂、ラード、バター、塩などのみを使用してください。回答は簡潔に、先ほどの要件に沿ってお答えください。"
        case .vegan:
            return "【重要】今回は「Vegan（完全菜食）モード」です。写真に写っている植物性食品（野菜、きのこ、大豆製品など）のみを使用し、肉や卵などの動物性食品は無視してください。調理油や調味料にも動物性エキスやバターなどは一切使わず、植物油、塩、醤油などのみを使用してください。回答は簡潔に、先ほどの要件に沿ってお答えください"
        }
    }
}

struct ContentView: View {
    //撮影した写真を一時的に保持する変数
    @State private var capturedImage: UIImage? = nil
    @State private var selectedMode: DietaryMode = .normal//デフォルトのモードはNormalにしておく
    
    var body: some View {
        ZStack {
            //もし写真がセットされていれば、結果画面に遷移する
            if let image = capturedImage {
                ResultView(image: image, mode: selectedMode) {
                    self.capturedImage = nil
                }
            } else {
                //写真がなければカメラ画面に遷移する
                CameraView(capturedImage: $capturedImage, selectedMode: $selectedMode)
            }
        }
    }
}
