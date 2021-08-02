//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import Photos

public class FetchCollectionsServiceImp: FetchCollectionsService {
    public func fetchCollections(with type: PHAssetCollectionType,
                                 subtype: PHAssetCollectionSubtype,
                                 options: PHFetchOptions? = nil) -> [MediaItemsCollection] {
        let result = PHAssetCollection.fetchAssetCollections(with: type,
                                                             subtype: subtype,
                                                             options: options)
        var collections = [MediaItemsCollection]()
        result.enumerateObjects { collection, _, _ in
            let collection = MediaItemsCollection(collection: collection)
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
