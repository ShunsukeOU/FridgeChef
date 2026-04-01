//
//  GeminiService.swift
//  FridgeChef
//
//  Created by Shunsuke Taira on 2026/04/01.
//

import Foundation
import UIKit

struct GeminiResponse: Codable, Sendable {
    let candidates: [Candidate]?
}
struct Candidate: Codable, Sendable {
    let content: GeminiContent?
}
struct GeminiContent: Codable, Sendable {
    let parts: [Part]?
}
struct Part: Codable, Sendable {
    let text: String?
}

class GeminiService {
    func analyzeImage(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion("画像の処理に失敗しました。もう一度撮影してください。")
            return
        }
        let base64Image = imageData.base64EncodedString()
        
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=\(AppConfig.geminiAPIKey)"//gemini-flash-latestを使用。
        guard let url = URL(string: urlString) else {
            completion("URLの作成に失敗しました。もう一度撮影してください。")
            return
        }
        
        let prompt = "この画像に写っている食材を分析し、一般的な調味料を組み合わせて作れる料理のレシピを一つ、次の要件に沿って教えてください。要件：１、まず食材を、「冷蔵庫内の食材：〇〇、〇〇、、」のように、箇条書きで示す。２、「提案する料理：〇〇（所要時間：〇〇分）」とシンプルに答える。３、「【材料：①、、】」「【手順】：①、、」のように、箇条書きかつわかりやすく、材料分量、と手順をまとめてください。焼いたり茹でたりレンジで調理が必要な場合は、その時間も記載してください。４、敬語で１〜３の内容を回答してください。その他の余分な文章は必要ありません。簡潔で構いませんので、なるべく早く回答をお願いいたします。"
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt],
                        [
                            "inlineData": [
                                "mimeType": "image/jpeg",
                                "data": base64Image
                            ]
                        ]
                    ]
                ]
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        //APIとの通信を実行
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion("通信エラー: \(error.localizedDescription)") }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { completion("データを受信できませんでした。") }
                return
            }
            //返答が返ってこないのでAPIからの生のデータをXcodeのコンソールに出力する
            if let rawJSON = String(data: data, encoding: .utf8) {
                print("🚨APIレスポンス: \(rawJSON)")
            }
            //受け取ったJSONデータをSwiftの構造体に変換してテキストを抽出
            do {
                let decodedResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
                let text = decodedResponse.candidates?.first?.content?.parts?.first?.text ?? "レシピを生成できませんでした。"
                
                //メインスレッド（UI更新用）で結果を返す
                DispatchQueue.main.async {
                    completion(text)
                }
            } catch {
                DispatchQueue.main.async { completion("解析エラー：もう一度撮影してください。") }
            }
        }.resume()
    }
}
