//
//  CachingImageManagerMock.swift
//  Example
//
//  Created by Evgeny Schwarzkopf on 21.05.2021.
//

import UIKit
import Photos
import MediaService

final class CachingImageManagerMock: PHCachingImageManager, CachingImageManager {
    var pencilData: Data?
    var initialAVAsset: AVAsset?
    private let videoURL: URL = .init(fileURLWithPath: "/Users/evgenijsvarckopf/MediaService/Sources/MediaService/Resource/VideoTest.mov")
    private let imageURL: URL = .init(fileURLWithPath: "/Users/evgenijsvarckopf/MediaService/Sources/MediaService/Resource/ImageTest.png")

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
        requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options) { image, _ in
            resultHandler(image)
        }
    }
}
