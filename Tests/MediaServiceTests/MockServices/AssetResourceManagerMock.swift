//
//  AssetResourceManagerMock.swift
//  MediaServiceTests
//
//  Created by Evgeny Schwarzkopf on 27.05.2021.
//

import UIKit
import Photos
import MediaService

final class AssetResourceManagerMock: AssetResourceManager {
    func writeData(for resource: PHAssetResource,
                   toFile url: URL,
                   options: PHAssetResourceRequestOptions?,
                   completion: @escaping (AVURLAsset) -> Void) {
        let videoURL: URL = .init(fileURLWithPath: "/Users/evgenijsvarckopf/MediaService/Sources/MediaService/Resource/VideoTest.mov")
        let asset = AVURLAsset(url: videoURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        completion(asset)
    }
}
