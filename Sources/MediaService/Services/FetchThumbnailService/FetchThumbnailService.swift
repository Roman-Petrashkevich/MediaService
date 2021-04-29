//
//  FetchThumbnailService.swift
//  Example
//
//  Created by Evgeny Schwarzkopf on 29.04.2021.
//

import Photos
import UIKit

public protocol FetchThumbnailService {

    typealias Completion<T> = (T) -> Void

    func fetchThumbnail(for asset: PHAsset,
                        size: CGSize,
                        manager: PHCachingImageManager,
                        thumbnailCache: NSCache<NSString, UIImage>,
                        contentMode: PHImageContentMode,
                        completion: @escaping Completion<UIImage?>)
}

public class FetchThumbnailServiceImp: FetchThumbnailService {

    public func fetchThumbnail(for asset: PHAsset,
                               size: CGSize,
                               manager: PHCachingImageManager,
                               thumbnailCache: NSCache<NSString, UIImage>,
                               contentMode: PHImageContentMode,
                               completion: @escaping Completion<UIImage?>) {
        if let thumbnail = thumbnailCache.object(forKey: asset.localIdentifier as NSString) {
            completion(thumbnail)
            return
        }

        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true

        manager.requestImage(for: asset,
                             targetSize: size,
                             contentMode: contentMode,
                             options: options) { (image: UIImage?, _) in
            if let image = image {
                thumbnailCache.setObject(image, forKey: asset.localIdentifier as NSString)
            }

            completion(image)
        }
    }

    public init() {}
}

