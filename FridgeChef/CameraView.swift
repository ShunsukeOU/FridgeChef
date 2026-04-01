import SwiftUI

struct CameraView: View {
    @Binding var capturedImage: UIImage?
    
    var body: some View {
        ZStack {
            // ここに後でAVFoundationのカメラ映像レイヤーを敷きます
            Color.black.edgesIgnoringSafeArea(.all)
            Text("カメラ起動中...")
                .foregroundColor(.white)
            
            VStack {
                Spacer()
                
                // シャッターボタン
                Button(action: {
                    // 🚨 ここで写真を撮影し、capturedImageにセットする処理を後で追加します
                    // 仮の処理として、システムアイコンを画像としてセットして画面遷移をテストします
                    capturedImage = UIImage(systemName: "refrigerator")
                }) {
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 3)
                        .background(Circle().fill(Color.white.opacity(0.8)))
                        .frame(width: 70, height: 70)
                }
                .padding(.bottom, 30)
            }
        }
    }
}