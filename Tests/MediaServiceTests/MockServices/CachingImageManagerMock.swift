//
//  CachingImageManagerMock.swift
//  Example
//
//  Created by Evgeny Schwarzkopf on 21.05.2021.
//

import UIKit
import Photos
import MediaService

final class CachingImageManagerMock: CachingImageManager {
    var pencilData: Data?
    private var bundle: Bundle {
        Bundle(for: Self.self)
    }
    private var videoURL: URL {
        URL(fileURLWithPath: bundle.path(forResource: "VideoTest", ofType: "mov") ?? "")
    }
    private var imageURL: URL {
        URL(fileURLWithPath: bundle.path(forResource: "ImageTest", ofType: "png") ?? "")
    }
    private var initialAVAsset: AVAsset {
        AVAsset(url: videoURL)
    }

    func requestImageData(for asset: PHAsset,
                          options: PHImageRequestOptions?,
                          resultHandler: @escaping (Data?) -> Void) {
        resultHandler(pencilData)
    }

    func requestLivePhoto(for asset: PHAsset,
                          targetSize: CGSize,
                          contentMode: PHImageContentMode,
                          options: PHLivePhotoRequestOptions?,
                          resultHandler: @escaping (PHLivePhoto?) -> Void) {
        PHLivePhoto.request(withResourceFileURLs: [videoURL, imageURL],
                            placeholderImage: nil,
                            targetSize: .zero,
                            contentMode: .default) { livePhoto, _ in
            guard livePhoto != nil else {
                return
            }
            resultHandler(livePhoto)
        }
    }

    func requestAVAsset(forVideo asset: PHAsset,
                        options: PHVideoRequestOptions?,
                        resultHandler: @escaping (AVAsset?) -> Void) {
        resultHandler(initialAVAsset)
    }

    func requestImage(for asset: PHAsset,
                      targetSize: CGSize,
                      contentMode: PHImageContentMode,
                      options: PHImageRequestOptions?,
                      resultHandler: @escaping (UIImage?) -> Void) {
        resultHandler(UIImage.init(systemName: "pencil"))
    }
}
