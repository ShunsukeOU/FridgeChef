//
//  ContentView.swift
//  FridgeChef
//
//  Created by Shunsuke Taira on 2026/04/01.
//

import SwiftUI

struct ContentView: View {
    //撮影した写真を一時的に保持する変数
    @State private var capturedImage: UIImage? = nil
    
    var body: some View {
        ZStack {
            //もし写真がセットされていれば、結果画面に遷移する
            if let image = capturedImage {
                ResultView(image: image) {
                    self.capturedImage = nil
                }
            } else {
                //写真がなければカメラ画面に遷移する
                CameraView(capturedImage: $capturedImage)
            }
        }
    }
}
