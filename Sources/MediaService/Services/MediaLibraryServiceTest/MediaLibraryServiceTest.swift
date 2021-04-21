//
//  MediaLibraryServiceTest.swift
//  Example
//
//  Created by Evgeny Schwarzkopf on 20.04.2021.
//

//import Ion
import Photos
//import UIKit

public protocol MediaLibraryServiceTest {
    func fetchCollections(with type: PHAssetCollectionType,
                          subtype: PHAssetCollectionSubtype,
                          options: PHFetchOptions?) -> [MediaItemCollection]
    func fetchAssetCollections(localIdentifiers: [String], options: PHFetchOptions?) -> PHAssetCollection?
    func requestMediaLibraryPermissions(handler: @escaping (PHAuthorizationStatus) -> Void)
}

public class MediaLibraryServiceTestImp: MediaLibraryServiceTest {
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

    public func requestMediaLibraryPermissions(handler: @escaping (PHAuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) in
            handler(status)
        }
    }
}
