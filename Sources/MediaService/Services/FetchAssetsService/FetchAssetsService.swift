//
//  FetchAssetsService.swift
//  MediaService
//
//  Created by Evgeny Schwarzkopf on 01.07.2021.
//

import Photos

public protocol HasFetchAssetsService {
    var fetchAssetsService: FetchAssetsService { get }
}

public protocol FetchAssetsService {
    func fetchAssets(assetCollection: PHAssetCollection) -> PHAsset?
    func makeAsset(item: MediaItem) -> PHAsset?
}
