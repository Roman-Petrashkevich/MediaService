//
//  MediaServiceMock.swift
//  MediaServiceTests
//
//  Created by Evgeny Schwarzkopf on 14.04.2021.
//

import MediaService
import Ion
import Photos

class MediaLibraryServiceTestMock: MediaLibraryServiceTest {
    static var status: PHAuthorizationStatus = .authorized
    static var mediaCollection: MediaItemCollection = .init(identifier: "12", title: "Recents")

    func fetchCollections(with type: PHAssetCollectionType, subtype: PHAssetCollectionSubtype, options: PHFetchOptions?) -> [MediaItemCollection] {
        [MediaLibraryServiceTestMock.mediaCollection]
    }

    func fetchAssetCollections(localIdentifiers: [String], options: PHFetchOptions?) -> PHAssetCollection? {
        let assetCollection: PHAssetCollection = .transientAssetCollection(with: [.init(), .init(), .init()],
                                                                           title: MediaLibraryServiceTestMock.mediaCollection.title)
        return assetCollection
    }

    func requestMediaLibraryPermissions(handler: @escaping (PHAuthorizationStatus) -> Void) {
        handler(MediaLibraryServiceTestMock.status)
    }
}
