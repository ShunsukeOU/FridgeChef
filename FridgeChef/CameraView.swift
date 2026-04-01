//
//  CameraView.swift
//  FridgeChef
//
//  Created by Shunsuke Taira on 2026/04/01.
//

import SwiftUI
import AVFoundation
import Combine
//画像取り込みの処理を担当するクラス
//写真フォルダに保存したくないので、AVCaptureを使って画面取り込みを行うようにする
class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var session = AVCaptureSession()
    @Published var output = AVCapturePhotoOutput()
    @Published var capturedImage: UIImage?
    
    //カメラのアクセス許可
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted { DispatchQueue.main.async { self.setupCamera() } }
            }
        default:
            print("カメラへのアクセス権がありません。")
        }
    }
    
    //カメラのセットアップ
    func setupCamera() {
        do {
            session.beginConfiguration()
            
            //メインカメラを取得
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
            let input = try AVCaptureDeviceInput(device: device)
            
            if session.canAddInput(input) { session.addInput(input) }
            if session.canAddOutput(output) { session.addOutput(output) }
            
            session.commitConfiguration()
            
            //カメラをバックグラウンドで起動
            DispatchQueue.global(qos: .background).async {
                self.session.startRunning()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //シャッターを切る処理
    func takePicture() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
    
    //写真が撮影された直後に呼ばれる処理（ここで画像データを受け取る）
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let data = photo.fileDataRepresentation(), let image = UIImage(data: data) {
            DispatchQueue.main.async {
                self.capturedImage = image//ここで変数に、画像を一時的に保存する
                self.session.stopRunning()//撮影したらカメラを停止する
            }
        }
    }
}

//カメラの映像をSwiftUIに映すための変換用ビュー
struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraModel
    
    func makeUIView(context: Context) -> UIView {
        let view = PreviewContainerView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: camera.session)
        previewLayer.videoGravity = .resizeAspectFill
        view.attachPreviewLayer(previewLayer)
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

private final class PreviewContainerView: UIView {
    private var previewLayer: AVCaptureVideoPreviewLayer?

    func attachPreviewLayer(_ layer: AVCaptureVideoPreviewLayer) {
        self.previewLayer?.removeFromSuperlayer()
        self.previewLayer = layer
        layer.frame = bounds
        layer.videoGravity = .resizeAspectFill
        self.layer.addSublayer(layer)
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
}

//実際の画面の見た目（UI）
struct CameraView: View {
    @Binding var capturedImage: UIImage?
    @StateObject var camera = CameraModel()
    
    //画面フラッシュを管理するための状態変数
    @State private var flashScreen = false
    
    var body: some View {
        ZStack {
            //カメラの映像を全画面に敷く
            CameraPreview(camera: camera)
                .ignoresSafeArea()
                //カメラ映像の上に白い画面を重ねる
                .overlay(
                    Color.white
                        .opacity(flashScreen ? 1 : 0)
                        .ignoresSafeArea()
                )
            
            VStack {
                Spacer()
                
                //シャッターボタン
                Button(action: {
                    //写真を撮る処理
                    camera.takePicture()
                    
                    //Haptic Feedback（端末を一瞬振動させる）
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    
                    //画面を一瞬だけ白く光らせるアニメーション
                    withAnimation(.linear(duration: 0.1)) {
                        flashScreen = true
                    }
                    //0.1秒後に元の透明に戻す
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.linear(duration: 0.1)) {
                            flashScreen = false
                        }
                    }
                    
                }) {
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 3)
                        .background(Circle().fill(Color.white.opacity(0.8)))
                        .frame(width: 70, height: 70)
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            camera.checkPermissions()
        }
        .onChange(of: camera.capturedImage) { oldValue, newValue in
                    if let image = newValue {
                        // 撮影アニメーションを見せるため、画面遷移をほんの少し（0.5秒）遅らせる
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            capturedImage = image
                        }
                    }
                }
    }
}
