//
//  AssetResourceManager.swift
//  MediaService
//
//  Created by Evgeny Schwarzkopf on 01.07.2021.
//

import Photos

public protocol HasAssetResourceManager {
    var assetResourceManager: AssetResourceManager { get }
}

public protocol AssetResourceManager: AnyObject {
    func writeData(for resource: PHAssetResource,
                   toFile url: URL,
                   options: PHAssetResourceRequestOptions?,
                   completion: @escaping (AVURLAsset) -> Void)
}
