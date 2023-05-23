//
//  FrameManager.swift
//  SwiftUI_Camera_Filter_Example
//
//  Created by cano on 2023/05/23.
//

import Foundation
import AVFoundation

// カメラ入力の変換用クラス
class FrameManager: NSObject, ObservableObject {
    
    // sharedプロパティでインスタンスにアクセスできるように
    static let shared = FrameManager()

    // バッファ出力用
    @Published var currentBuffer: CVPixelBuffer?

    let videoOutputQueue = DispatchQueue(
                                label: "videoOutputQ",
                                qos: .userInitiated,
                                attributes: [],
                                autoreleaseFrequency: .workItem)

    override init() {
        super.init()
        // カメラ管理クラスにキューをセット
        CameraManager.shared.set(self, queue: videoOutputQueue)
    }
}

// Delegate実装 カメラ入力からバッファを取得する
extension FrameManager: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput( _ output: AVCaptureOutput,didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
      
      if let buffer = sampleBuffer.imageBuffer {
          DispatchQueue.main.async {
              self.currentBuffer = buffer
          }
      }
  }
}
