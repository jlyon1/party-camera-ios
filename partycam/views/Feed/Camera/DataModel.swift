/*
See the License.txt file for this sample’s licensing information.
*/

import AVFoundation
import SwiftUI
import os.log

final class DataModel: ObservableObject {
    let backend: BackendManager
    let camera = Camera()
    let eventId: Int
    let eventName: String

    @Published var viewfinderImage: Image?
    @Published var thumbnailImage: Image?
    
    private var uploadQueue = [Data]()    // holds imageData for upload
    private var isUploading = false       // upload status
    
    var isPhotosLoaded = false
    
    init(backend: BackendManager, eventId: Int, eventName: String) {
        self.backend = backend
        self.eventId = eventId
        self.eventName = eventName
        Task {
            await handleCameraPreviews()
        }
        
        Task {
            await handleCameraPhotos()
        }
    }
    
    func handleCameraPreviews() async {
		let context = CIContext(options: [.cacheIntermediates: false,
										  .name: "handleCameraPreviews"])
        logger.info("Previews Started")
        let imageStream = camera.previewStream
			.map { $0.image(ciContext: context) }

        for await image in imageStream {
            Task { @MainActor in
                viewfinderImage = image
            }
        }
    }

    
    func handleCameraPhotos() async {
        let unpackedPhotoStream = camera.photoStream
            .compactMap { self.unpackPhoto($0) }
        
        for await photoData in unpackedPhotoStream {
            Task { @MainActor in
                thumbnailImage = photoData.thumbnailImage
            }
            enqueuePhotoForUpload(photoData.imageData)
        }
    }
    
    func enqueuePhotoForUpload(_ imageData: Data) {
        uploadQueue.append(imageData)
        tryUploadNext()
    }
    
    func tryUploadNext() {
        guard !isUploading, !uploadQueue.isEmpty else { return }
        isUploading = true
        let nextPhoto = uploadQueue.removeFirst()

        Task {
            await uploadPhoto(imageData: nextPhoto)
            isUploading = false
            tryUploadNext()
        }
    }
    
    private func unpackPhoto(_ photo: AVCapturePhoto) -> PhotoData? {
        guard let imageData = photo.fileDataRepresentation() else { return nil }

        guard let previewCGImage = photo.previewCGImageRepresentation(),
           let metadataOrientation = photo.metadata[String(kCGImagePropertyOrientation)] as? UInt32,
              let cgImageOrientation = CGImagePropertyOrientation(rawValue: metadataOrientation) else { return nil }
        let imageOrientation = Image.Orientation(cgImageOrientation)
        let thumbnailImage = Image(decorative: previewCGImage, scale: 1, orientation: imageOrientation)
        
        let photoDimensions = photo.resolvedSettings.photoDimensions
        let imageSize = (width: Int(photoDimensions.width), height: Int(photoDimensions.height))
        let previewDimensions = photo.resolvedSettings.previewDimensions
        let thumbnailSize = (width: Int(previewDimensions.width), height: Int(previewDimensions.height))
        
        return PhotoData(thumbnailImage: thumbnailImage, thumbnailSize: thumbnailSize, imageData: imageData, imageSize: imageSize)
    }
    

    func uploadPhoto(imageData: Data) async {
        do {
            let result = try await backend.fetchPresignedUpload(contentType: "image/jpeg", eventId: eventId)
            guard let url = URL(string: result.signedUrl) else { return }

            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
            request.httpBody = imageData

            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                print("Upload successful!")
            } else {
                print("Upload failed with status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                // Optionally re-queue the photo for retry
            }
        } catch {
            print("Upload error: \(error)")
            // Optionally re-queue the photo for retry
        }
    }
    
    func loadPhotos() async {
        
        Task {
            // TODO
        }
    }
    
    func loadThumbnail() async {
        // TODO
    }
}

fileprivate struct PhotoData {
    var thumbnailImage: Image
    var thumbnailSize: (width: Int, height: Int)
    var imageData: Data
    var imageSize: (width: Int, height: Int)
}

fileprivate extension CIImage {
	func image(ciContext: CIContext) -> Image? {
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}

fileprivate extension Image.Orientation {

    init(_ cgImageOrientation: CGImagePropertyOrientation) {
        switch cgImageOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}

fileprivate let logger = Logger(subsystem: "com.apple.swiftplaygroundscontent.capturingphotos", category: "DataModel")
