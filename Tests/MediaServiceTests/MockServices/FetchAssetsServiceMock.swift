//
//  FetchAssetsServiceMock.swift
//  Example
//
//  Created by Evgeny Schwarzkopf on 29.04.2021.
//

import MediaService
import Photos

final class FetchAssetsServiceMock: FetchAssetsService {

    var fetchAsset: PHAsset? = .init()
    var makeAsset: PHAsset? = .init()

    func fetchAssets(assetCollection: PHAssetCollection) -> PHAsset? {
        fetchAsset
    }

    func makeAsset(item: MediaItem) -> PHAsset? {
        makeAsset
    }
}
