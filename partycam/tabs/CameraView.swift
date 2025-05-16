import SwiftUI
import AVFoundation

import SwiftUI

struct CameraView: View {
    var body: some View {
        ZStack {
            CameraPreviewView()
            VStack {
                Spacer()
                Button(action: {
                    // TODO: Handle capture action
                }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 70, height: 70)
                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                        .padding()
                }
            }
        }
    }
}

import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    class CameraPreview: UIView {
        private let session = AVCaptureSession()
        private let previewLayer = AVCaptureVideoPreviewLayer()

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupCamera()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupCamera()
        }

        private func setupCamera() {
            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input) else { return }

            session.addInput(input)

            previewLayer.session = session
            previewLayer.videoGravity = .resizeAspectFill
            layer.addSublayer(previewLayer)

            session.startRunning()
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            previewLayer.frame = bounds
        }
    }

    func makeUIView(context: Context) -> UIView {
        return CameraPreview()
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
