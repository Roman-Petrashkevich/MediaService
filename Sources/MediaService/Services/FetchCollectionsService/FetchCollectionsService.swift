//
//  MediaLibraryServiceTest.swift
//  Example
//
//  Created by Evgeny Schwarzkopf on 20.04.2021.
//

import Photos

public protocol FetchCollectionsService {
    func fetchCollections(with type: PHAssetCollectionType,
                          subtype: PHAssetCollectionSubtype,
                          options: PHFetchOptions?) -> [MediaItemCollection]
    func fetchAssetCollections(localIdentifiers: [String], options: PHFetchOptions?) -> PHAssetCollection?
    func fetchMediaItems(in collection: PHAssetCollection, mediaType: PHAssetMediaType?) -> PHFetchResult<PHAsset>?
}

public class FetchCollectionsServiceImp: FetchCollectionsService {
    public func fetchCollections(with type: PHAssetCollectionType,
                                 subtype: PHAssetCollectionSubtype,
                                 options: PHFetchOptions? = nil) -> [MediaItemCollection] {
        let result = PHAssetCollection.fetchAssetCollections(with: type,
                                                             subtype: subtype,
                                                             options: options)
        var collections = [MediaItemCollection]()
        result.enumerateObjects { collection, _, _ in
            let collection = MediaItemCollection(collection: collection)
            collections.append(collection)
        }
        return collections
    }

    public func fetchAssetCollections(localIdentifiers: [String], options: PHFetchOptions?) -> PHAssetCollection? {
        guard let assetCollection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: localIdentifiers,
                                                                            options: nil).firstObject else {
            return nil
        }
        return assetCollection
    }

    public func fetchMediaItems(in collection: PHAssetCollection,
                                mediaType: PHAssetMediaType?) -> PHFetchResult<PHAsset>? {
        let options = PHFetchOptions()

        if let mediaType = mediaType {
            options.predicate = NSPredicate(format: "mediaType = %d", mediaType.rawValue)
        }

        return PHAsset.fetchAssets(in: collection, options: options)
    }

    public init() {}
}
