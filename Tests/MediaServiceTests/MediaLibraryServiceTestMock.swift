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
    private let mediaCollection: MediaItemCollection = .init(identifier: "12", title: "Recents")
    static var assets: [PHAsset] = []

    func fetchCollections(with type: PHAssetCollectionType,
                          subtype: PHAssetCollectionSubtype,
                          options: PHFetchOptions?) -> [MediaItemCollection] {
        [mediaCollection]
    }

    func fetchAssetCollections(localIdentifiers: [String], options: PHFetchOptions?) -> PHAssetCollection? {
        .transientAssetCollection(with: MediaLibraryServiceTestMock.assets, title: localIdentifiers.first)
    }

    func requestMediaLibraryPermissions(handler: @escaping (PHAuthorizationStatus) -> Void) {
        handler(MediaLibraryServiceTestMock.status)
    }
}
