//
//  CameraManager.swift
//  SwiftUI_Camera_Filter_Example
//
//  Created by cano on 2023/05/23.
//

import Foundation
import AVFoundation

// カメラ管理クラス
class CameraManager: ObservableObject {
    enum Status {
        case unconfigured
        case configured
        case unauthorized
        case failed
    }
    
    // sharedプロパティでインスタンスにアクセスできるように
    static let shared = CameraManager()

    // エラー
    @Published var error: CameraError?

    // 映像セッション関係
    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "session") // 同じキューの中で処理を行うように 複数クラスからコールするため
    private let videoOutput = AVCaptureVideoDataOutput()
    private var status = Status.unconfigured

    init() {
        self.checkPermissions()

        /*sessionQueue.async {
            self.configureCaptureSession()
            // セッション開始
            self.session.startRunning()
        }*/
    }
    
    // 開始
    func start() {
        sessionQueue.async {
            self.configureCaptureSession()
            // セッション開始
            self.session.startRunning()
        }
    }
    
    // 終了
    func stop() {
        self.session.stopRunning()
    }

    // エラー
    private func setError(_ error: CameraError?) {
        DispatchQueue.main.async {
          self.error = error
        }
    }
    
    // カメラ利用可能か？
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { authorized in
                if !authorized {
                    self.status = .unauthorized
                    self.setError(.deniedAuthorization)
                }
                self.sessionQueue.resume()
            }
        case .restricted:
            status = .unauthorized
            setError(.restrictedAuthorization)
        case .denied:
            status = .unauthorized
            setError(.deniedAuthorization)
        case .authorized:
            break
        @unknown default:
            status = .unauthorized
            setError(.unknownAuthorization)
        }
    }

    // セッションの初期化と管理
    private func configureCaptureSession() {
        guard status == .unconfigured else {
          return
        }

        session.beginConfiguration()

        defer {
            session.commitConfiguration()
        }

        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        guard let camera = device else {
            setError(.cameraUnavailable)
            status = .failed
            return
        }

        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(cameraInput) {
                session.addInput(cameraInput)
            } else {
                setError(.cannotAddInput)
                status = .failed
                return
            }
        } catch {
            setError(.createCaptureInput(error))
            status = .failed
            return
        }

        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)

            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]

            let videoConnection = videoOutput.connection(with: .video)
            videoConnection?.videoOrientation = .portrait
        } else {
            setError(.cannotAddOutput)
            status = .failed
            return
        }

        // ステータスOK
        status = .configured
    }

    // Delegate設定
    func set(_ delegate: AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue) {
        sessionQueue.async {
            self.videoOutput.setSampleBufferDelegate(delegate, queue: queue)
        }
    }
}
