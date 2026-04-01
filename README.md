# FridgeChef

冷蔵庫内の食材をカメラで撮影し、Google Gemini APIを用いて解析・レシピ提案を行うiOSアプリケーションです。

---

## Features

本プロジェクトはSwiftUIとAVFoundationを組み合わせたカメラ機能を用いて、撮影した画像をAIで解析することで、手持ちの食材から最適なレシピを提案します。

---

## Tech Stacks

- **開発に用いた言語**: Swift 6.2
- **Framework**: SwiftUI, UIKit, AVFoundation
- **AI Engine**: Google Gemini API (gemini-flash-latest)
- **Deployment Target**: iOS/iPadOS 26.4
- **実機ビルドに使用した機材**: iPhone 17e
---

## プロジェクト構造

プロジェクトの主要なファイルとその役割は以下の通りです。

| ファイル                  | 役割 |
|--------------------------|------|
| `FridgeChefApp.swift`    | 起動時に読み込まれるファイル |
| `ContentView.swift`      | 撮影前（カメラ表示）と撮影後（解析結果表示）の画面遷移を管理 |
| `CameraView.swift`       | AVCaptureSessionを使用したカメラ制御および、撮影した画像データを一時的に保持するためのコード |
| `GeminiService.swift`    | 撮影画像のBase64エンコード、プロンプト構築、Google APIへのリクエストおよびレスポンスを処理 |
| `ResultView.swift`       | AIから取得したレシピテキストのレンダリング |
| `Config.example.swift` | API キーを管理する定数ファイル |

---

## セットアップ手順

プロジェクトをクローンして動作させるための手順です。

---

### 1. プロジェクトの準備

```bash
# リポジトリをクローン
git clone https://github.com/yourusername/FridgeChef.git

# プロジェクトディレクトリに移動
cd FridgeChef
```

---

### 2. APIキーの設定

1.プロジェクトルートに Config.swift ファイルを作成

2.以下の形式で Google Gemini API キーを設定してください：

```bash
// Config.swift
struct Config {
    static let geminiAPIKey = "ここに取得したAPIキーを挿入"
}
```

3.Xcodeでプロジェクトを開く（ターミナルでプロジェクトフォルダに移動後、実行してください。）
```bash
open FridgeChef.xcodeproj
```

4.ビルドと実行
Xcodeで実行ボタンを押して実行（カメラ機能を利用しているので、動作確認には実機でのビルドおよびカメラ機能へのアクセス権付与が必要です。）

---

2026.04.01 Shunsuke Taira
