//
//  CachingImageManager.swift
//  Example
//
//  Created by Evgeny Schwarzkopf on 21.05.2021.
//

import Foundation
import Photos
import UIKit

public class CachingImageManagerImp: PHCachingImageManager, CachingImageManager {
    public func requestImageData(for asset: PHAsset,
                                 options: PHImageRequestOptions?,
                                 resultHandler: @escaping (Data?) -> Void) {
        requestImageData(for: asset, options: options) { data, _, _, _ in
            resultHandler(data)
        }
    }

    public func requestAVAsset(forVideo asset: PHAsset,
                               options: PHVideoRequestOptions?,
                               resultHandler: @escaping (AVAsset?) -> Void) {
        requestAVAsset(forVideo: asset, options: options) { aVAsset, _, _ in
            resultHandler(aVAsset)
        }
    }

    public func requestLivePhoto(for asset: PHAsset,
                                 targetSize: CGSize,
                                 contentMode: PHImageContentMode,
                                 options: PHLivePhotoRequestOptions?,
                                 resultHandler: @escaping (PHLivePhoto?) -> Void) {
        requestLivePhoto(for: asset, targetSize: targetSize, contentMode: contentMode, options: options) { livePhoto, _ in
            resultHandler(livePhoto)
        }
    }

    public func requestImage(for asset: PHAsset,
                             targetSize: CGSize,
                             contentMode: PHImageContentMode,
                             options: PHImageRequestOptions?,
                             resultHandler: @escaping (UIImage?) -> Void) {
        requestImage(for: asset,
                     targetSize: targetSize,
                     contentMode: contentMode,
                     options: options) { image, _ in
            resultHandler(image)
        }
    }
}
