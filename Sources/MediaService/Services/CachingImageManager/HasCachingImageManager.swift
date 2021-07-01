//
//  HasCachingImageManager.swift
//  MediaService
//
//  Created by Evgeny Schwarzkopf on 01.07.2021.
//

import Foundation
import Photos
import UIKit

public protocol HasCachingImageManager {
    var cachingImageManager: CachingImageManager { get }
}

public protocol CachingImageManager: AnyObject {
    func requestImageData(for asset: PHAsset,
                          options: PHImageRequestOptions?,
                          resultHandler: @escaping (Data?) -> Void)
    func requestAVAsset(forVideo asset: PHAsset,
                        options: PHVideoRequestOptions?,
                        resultHandler: @escaping (AVAsset?) -> Void)
    func requestLivePhoto(for asset: PHAsset,
                          targetSize: CGSize,
                          contentMode: PHImageContentMode,
                          options: PHLivePhotoRequestOptions?,
                          resultHandler: @escaping (PHLivePhoto?) -> Void)
    func requestImage(for asset: PHAsset,
                      targetSize: CGSize,
                      contentMode: PHImageContentMode,
                      options: PHImageRequestOptions?,
                      resultHandler: @escaping (UIImage?) -> Void)
}
