//
//  FetchCollectionsService.swift
//  MediaService
//
//  Created by Evgeny Schwarzkopf on 01.07.2021.
//

import Photos

public protocol HasFetchCollectionsService {
    var fetchCollectionsService: FetchCollectionsService { get }
}

public protocol FetchCollectionsService {
    func fetchCollections(with type: PHAssetCollectionType,
                          subtype: PHAssetCollectionSubtype,
                          options: PHFetchOptions?) -> [MediaItemsCollection]
    func fetchAssetCollections(localIdentifiers: [String], options: PHFetchOptions?) -> PHAssetCollection?
    func fetchMediaItems(in collection: PHAssetCollection, mediaType: PHAssetMediaType?) -> PHFetchResult<PHAsset>?
}
