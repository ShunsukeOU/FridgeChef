//
//  GeminiService.swift
//  FridgeChef
//
//  Created by 平良隼涼 on 2026/04/01.
//

import SwiftUI

// APIからの返却データ（JSON）をSwiftで扱いやすくするための構造体
struct GeminiResponse: Codable {
    let candidates: [Candidate]?
}
struct Candidate: Codable {
    let content: GeminiContent?
}
struct GeminiContent: Codable {
    let parts: [Part]?
}
struct Part: Codable {
    let text: String?
}

class GeminiService {
    func analyzeImage(image: UIImage, completion: @escaping (String?) -> Void) {
        // 1. 画像を軽量化してBase64文字列に変換（APIの制限対策）
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion("画像の処理に失敗しました。")
            return
        }
        let base64Image = imageData.base64EncodedString()
        
        // 2. APIエンドポイントのURL作成
        // ここでは無料でマルチモーダル（画像＋テキスト）が使える gemini-1.5-flash モデルを指定します
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=\(Config.geminiAPIKey)"
        guard let url = URL(string: urlString) else {
            completion("URLの作成に失敗しました。")
            return
        }
        
        // 3. 送信するJSONデータ（リクエストボディ）の組み立て
        let prompt = "この画像に写っている食材を分析し、一般的な調味料を組み合わせて作れる料理のレシピを3つ、手順付きで提案してください。"
        
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
        
        // 4. APIとの通信を実行
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion("通信エラー: \(error.localizedDescription)") }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { completion("データを受信できませんでした。") }
                return
            }
            
            // 5. 受け取ったJSONデータをSwiftの構造体に変換してテキストを抽出
            do {
                let decodedResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
                let text = decodedResponse.candidates?.first?.content?.parts?.first?.text ?? "レシピを生成できませんでした。"
                
                // メインスレッド（UI更新用）で結果を返す
                DispatchQueue.main.async {
                    completion(text)
                }
            } catch {
                DispatchQueue.main.async { completion("解析エラー: 開発者向け(JSONの形式が想定と異なります)") }
            }
        }.resume()
    }
}
