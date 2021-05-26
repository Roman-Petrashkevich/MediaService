//
//  FetchCollectionServiceMock.swift
//  Example
//
//  Created by Evgeny Schwarzkopf on 28.04.2021.
//

import Photos
import MediaService

final class FetchCollectionServiceMock: FetchCollectionsService {
    private let mediaCollection: MediaItemCollection = .init(identifier: "12", title: "Recents")
    var assets: [PHAsset] = []

    func fetchCollections(with type: PHAssetCollectionType,
                          subtype: PHAssetCollectionSubtype,
                          options: PHFetchOptions?) -> [MediaItemCollection] {
        [mediaCollection]
    }

    func fetchAssetCollections(localIdentifiers: [String], options: PHFetchOptions?) -> PHAssetCollection? {
        .transientAssetCollection(with: assets, title: localIdentifiers.first)
    }

    func fetchMediaItems(in collection: PHAssetCollection, mediaType: PHAssetMediaType?) -> PHFetchResult<PHAsset>? {
        let options = PHFetchOptions()

        if let mediaType = mediaType {
            options.predicate = NSPredicate(format: "mediaType = %d", mediaType.rawValue)
        }

        return PHAsset.fetchAssets(in: collection, options: options)
    }
}
