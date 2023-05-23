//
//  ViewModel.swift
//  SwiftUI_Camera_Filter_Example
//
//  Created by cano on 2023/05/23.
//

import Foundation
import CoreImage
import Combine

class ViewModel: ObservableObject {
    // カメラ映像を変換したCGImage出力
    @Published var frame: CGImage?
    // エラー出力用変数
    @Published var error: Error?

    @Published var startSelected   = false
    var comicFilter     = false
    var monoFilter      = false
    var crystalFilter   = false

    // MARK: - Private
    private let context = CIContext()
    private let cameraManager = CameraManager.shared
    private let frameManager = FrameManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // 撮影開始／終了の値を受ける
    private let startSubject = PassthroughSubject<Bool, Never>()
    
    // 撮影開始／終了の値がくると処理が走る
    private var startPublisher: AnyPublisher<Bool, Never> {
        return startSubject.eraseToAnyPublisher()
    }
    
    init() {
        // エラー出力
        self.cameraManager.$error
            .receive(on: RunLoop.main)
            .map { $0 }
            .assign(to: &$error)

        // バッファ変換
        self.frameManager.$currentBuffer
            .receive(on: RunLoop.main)
            .compactMap { buffer in
                guard let image = CGImage.create(from: buffer) else { return nil }

                var ciImage = CIImage(cgImage: image)

                if self.comicFilter {
                    ciImage = ciImage.applyingFilter("CIComicEffect")
                }

                if self.monoFilter {
                    ciImage = ciImage.applyingFilter("CIPhotoEffectNoir")
                }

                if self.crystalFilter {
                    ciImage = ciImage.applyingFilter("CICrystallize")
                }
                // CIImageをCGImageに変換
                return self.context.createCGImage(ciImage, from: ciImage.extent)
          }
          .assign(to: &$frame)
        
        // 撮影開始／終了
        $startSelected.sink(receiveValue: { [weak self] bool in
            self?.startSubject.send(bool)
        })
        .store(in: &cancellables)
        
        // トリガ起動
        self.startSubject
            .sink { [weak self] value in
                if value {
                    self?.cameraManager.start()
                } else {
                    self?.cameraManager.stop()
                }
            }
            .store(in: &cancellables)
    }
}

