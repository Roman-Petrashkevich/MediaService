//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import XCTest
@testable import MediaService
import Ion
import Photos

final class MediaServiceTests: XCTestCase {

    typealias Dependencies = HasFetchCollectionsService &
                             HasPermissionsService &
                             HasFetchAssetsService &
                             HasThumbnailCacheService &
                             HasCachingImageManager &
                             HasAssetResourceManager

    let dependencies: Dependencies = TestServices

    private lazy var fetchCollectionsServiceMock: FetchCollectionServiceMock = {
        let service = dependencies.fetchCollectionsService as? FetchCollectionServiceMock
        return service ?? FetchCollectionServiceMock()
    }()
    private lazy var permissionsServiceMock: PermissionsServiceMock = {
        let service = dependencies.permissionsService as? PermissionsServiceMock
        return service ?? PermissionsServiceMock()
    }()
    private lazy var thumbnailCacheServiceMock: ThumbnailCacheServiceMock = {
        let service = dependencies.thumbnailCacheService as? ThumbnailCacheServiceMock
        return service ?? ThumbnailCacheServiceMock()
    }()
    private lazy var fetchAssetServiceMock: FetchAssetsServiceMock = {
        let service = dependencies.fetchAssetsService as? FetchAssetsServiceMock
        return service ?? FetchAssetsServiceMock()
    }()
    private lazy var cachingImageManagerMock: CachingImageManagerMock = {
        let service = dependencies.cachingImageManager as? CachingImageManagerMock
        return service ?? CachingImageManagerMock()
    }()
    private lazy var assetResourceManagerMock: AssetResourceManagerMock = {
        let service = dependencies.assetResourceManager as? AssetResourceManagerMock
        return service ?? AssetResourceManagerMock()
    }()

    private var bundle: Bundle {
        Bundle(for: Self.self)
    }

    private var imagePath: String {
        bundle.path(forResource: "ImageTest", ofType: "png") ?? ""
    }

    lazy var service: MediaLibraryService = {
        let service = MediaLibraryServiceImp(dependencies: dependencies)
        return service
    }()

    private lazy var permissionStatusCollector: Collector<PHAuthorizationStatus> = {
        return .init(source: service.permissionStatusEventSource)
    }()

    private lazy var mediaItemCollectionsCollector: Collector<[MediaItemsCollection]> = {
        return .init(source: service.collectionsEventSource)
    }()

    private lazy var mediaItemResultCollector: Collector<MediaItemsFetchResult> = {
        return .init(source: service.mediaItemsEventSource)
    }()

    private lazy var mediaLibraryUpdateCollector: Collector<PHChange> = {
        return .init(source: service.mediaLibraryUpdateEventSource)
    }()

    private lazy var mediaItemFetchProgressCollector: Collector<Float> = {
        .init(source: service.mediaItemFetchProgressEventSource)
    }()

    // MARK: - PermissionTest

    func testPermissionAuthorizedStatus() {
        // Given
        let authStatus: PHAuthorizationStatus = .authorized
        let expectation = self.expectation(description: "error")
        // When
        permissionsServiceMock.status = .authorized
        service.requestMediaLibraryPermissions()
        // Then
        permissionStatusCollector.subscribe { status in
            XCTAssertEqual(status, authStatus, "Permission status is not equal")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testPermissionDeniedStatus() {
        // Given
        let authStatus: PHAuthorizationStatus = .denied
        let expectation = self.expectation(description: "error")
        // When
        permissionsServiceMock.status = .denied
        service.requestMediaLibraryPermissions()
        // Then
        permissionStatusCollector.subscribe { status in
            XCTAssertEqual(status, authStatus, "Permission status is not equal")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testPermissionNotDeterminedStatus() {
        // Given
        let authStatus: PHAuthorizationStatus = .notDetermined
        let expectation = self.expectation(description: "error")
        // When
        permissionsServiceMock.status = .notDetermined
        service.requestMediaLibraryPermissions()
        // Then
        permissionStatusCollector.subscribe { status in
            XCTAssertEqual(status, authStatus, "Permission status is not equal")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testPermissionRestrictedStatus() {
        // Given
        let authStatus: PHAuthorizationStatus = .restricted
        let expectation = self.expectation(description: "error")
        // When
        permissionsServiceMock.status = .restricted
        service.requestMediaLibraryPermissions()
        // Then
        permissionStatusCollector.subscribe { status in
            XCTAssertEqual(status, authStatus, "Permission status is not equal")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testPermissionLimitedStatus() {
        if #available(iOS 14, *) {
            // Given
            let authStatus: PHAuthorizationStatus = .limited
            let expectation = self.expectation(description: "error")
            // When
            permissionsServiceMock.status = .limited
            service.requestMediaLibraryPermissions()
            // Then
            permissionStatusCollector.subscribe { status in
                XCTAssertEqual(status, authStatus, "Permission status is not equal")
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 1)
        }
    }

    func testPermissionAuthorizedStatusIsNotEqual() {
        // Given
        let authStatus: PHAuthorizationStatus = .authorized
        let expectation = self.expectation(description: "error")
        // When
        permissionsServiceMock.status = .notDetermined
        service.requestMediaLibraryPermissions()
        // Then
        permissionStatusCollector.subscribe { status in
            XCTAssertNotEqual(status, authStatus, "Permission status is equal")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    // MARK: - FetchMediaItemCollectorTest

    func testFetchMediaItemCollectionsCollector() {
        // Given
        let mediaItemCollectionsMock: [MediaItemsCollection] = [
            .init(identifier: "12", title: "Recents")]
        let expectation = self.expectation(description: "error")
        // When
        service.fetchMediaItemCollections()
        // Then
        mediaItemCollectionsCollector.subscribe { mediaItemCollections in
            XCTAssertEqual(mediaItemCollectionsMock.first?.identifier, mediaItemCollections.first?.identifier, "is not equal identifier")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 4)
    }

    // MARK: - FetchMediaItemsResultTest

    func testFetchMediaItemsResultWithFilterAll() {
        // Given
        let mediaItemCollectionsMock: MediaItemsCollection = .init(identifier: "12", title: "Recents")
        let mediaTypes: [PHAssetMediaType] = [.video, .image, .image]
        let expectation = self.expectation(description: "error")
        // When
        service.fetchMediaItems(in: mediaItemCollectionsMock, filter: .all)
        fetchCollectionsServiceMock.assets = [.init(), .init(), .init()]
        // Then
        mediaItemResultCollector.subscribe { mediaResult in
            XCTAssertEqual(MediaItemsFilter.all, mediaResult.filter, "is not equal filter")
            XCTAssertEqual(mediaTypes.count, mediaResult.fetchResult.count, "is not equal count")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 4)
    }

    func testFetchMediaItemsResultWithFilterVideo() {
        // Given
        let mediaItemCollectionsMock: MediaItemsCollection = .init(identifier: "12", title: "Recents")
        let mediaTypes: [PHAssetMediaType] = [.video]
        let expectation = self.expectation(description: "error")
        // When
        service.fetchMediaItems(in: mediaItemCollectionsMock, filter: .video)
        fetchCollectionsServiceMock.assets = [.init()]
        // Then
        mediaItemResultCollector.subscribe { mediaResult in
            XCTAssertEqual(MediaItemsFilter.video, mediaResult.filter, "is not equal filter")
            XCTAssertEqual(mediaTypes.count, mediaResult.fetchResult.count, "is not equal count")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 4)
    }

    // MARK: - FetchMediaItemThumbnailTest

    func testFetchMediaItemThumbnail() {
        // Given
        let mediaItem: MediaItem = .init(asset: .init())
        let pencilImage = UIImage(contentsOfFile: imagePath)
        mediaItem.thumbnail = pencilImage
        let expectation = self.expectation(description: "error")
        // Then
        service.fetchThumbnail(for: mediaItem, size: mediaItem.thumbnail?.size ?? .zero, contentMode: .aspectFill) { image in
            XCTAssertEqual(mediaItem.thumbnail, image, "is not equal image")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 4)
    }

    func testFetchMediaItemThumbnailIsNil() {
        // Given
        let mediaItem: MediaItem = .dummy
        let expectation = self.expectation(description: "error")
        // When
        fetchAssetServiceMock.makeAssetMock = nil
        thumbnailCacheServiceMock.thumbnailCache.removeAllObjects()
        // Then
        service.fetchThumbnail(for: mediaItem, size: .zero, contentMode: .aspectFill) { image in
            XCTAssertNil(image, "is not nil")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)
    }

    func testFetchMediaItemThumbnailFromCache() {
        // Given
        let mediaItem: MediaItem = .dummy
        let pencilImage = UIImage(contentsOfFile: imagePath)
        let expectation = self.expectation(description: "error")
        // When
        let key = fetchAssetServiceMock.fetchAssetMock?.localIdentifier ?? ""
        thumbnailCacheServiceMock.thumbnailCache.removeAllObjects()
        thumbnailCacheServiceMock.thumbnailCache.setObject(pencilImage ?? UIImage(),
                                                           forKey: key as NSString)
        // Then
        service.fetchThumbnail(for: mediaItem, size: .zero, contentMode: .aspectFill) { image in
            XCTAssertEqual(pencilImage, image, "is not equal image")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 4)
    }

    // MARK: - FethcMediaCollectionThumbnailTest

    func testFetchMediaCollectionThumbnail() {
        // Given
        let mediaItemCollections: MediaItemsCollection = .init(identifier: "12", title: "Recents")
        let pencilImage = UIImage(contentsOfFile: imagePath)
        mediaItemCollections.thumbnail = pencilImage
        let expectation = self.expectation(description: "error")
        // Then
        service.fetchThumbnail(for: mediaItemCollections, size: pencilImage?.size ?? .zero, contentMode: .aspectFill) { image in
            XCTAssertEqual(mediaItemCollections.thumbnail, image, "is not equal image")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 4)
    }

    func testFetchMediaCollectionThumbnailFromCache() {
        // Given
        let mediaItemCollection: MediaItemsCollection = .init(identifier: "12", title: "Recents")
        let pencilImage = UIImage(contentsOfFile: imagePath)
        let expectation = self.expectation(description: "error")
        // When
        let key = fetchAssetServiceMock.fetchAssetMock?.localIdentifier ?? ""
        thumbnailCacheServiceMock.thumbnailCache.removeAllObjects()
        thumbnailCacheServiceMock.thumbnailCache.setObject(pencilImage ?? UIImage(),
                                                           forKey: key as NSString)
        // Then
        service.fetchThumbnail(for: mediaItemCollection, size: .zero, contentMode: .aspectFill) { image in
            XCTAssertEqual(pencilImage, image, "is not equal image")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testFetchImage() {
        // Given
        let mediaItem: MediaItem = .init(asset: .init())
        let pencilData = UIImage(contentsOfFile: imagePath)?.pngData() ?? .init()
        let pencilImage = UIImage(data: pencilData)
        let expectation = self.expectation(description: "error")
        // When
        cachingImageManagerMock.pencilData = pencilData
        // Then
        service.fetchImage(for: mediaItem) { image in
            XCTAssertEqual(pencilImage?.pngData(), image?.pngData(), "is not equal image")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 4)
    }

    func testFetchImageIsNotEqual() {
        // Given
        let mediaItem: MediaItem = .init(asset: .init())
        let pencilData = UIImage(contentsOfFile: imagePath)?.pngData() ?? .init()
        let pencilImage = UIImage(contentsOfFile: imagePath)
        let expectation = self.expectation(description: "error")
        // When
        cachingImageManagerMock.pencilData = pencilImage?.jpegData(compressionQuality: 0.5)
        // Then
        service.fetchImage(for: mediaItem) { image in
            XCTAssertNotEqual(pencilImage?.pngData(), image?.pngData(), "is equal image")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 4)
    }

    func testFetchImageNil() {
        // Given
        let mediaItem: MediaItem = .init(asset: .init())
        let expectation = self.expectation(description: "error")
        // When
        cachingImageManagerMock.pencilData = nil
        // Then
        service.fetchImage(for: mediaItem) { image in
            XCTAssertNil(image, "is not nil")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 4)
    }

    func testFetchAVAssetWithVideo() {
        // Given
        let mediaItem: MediaItem = .init(asset: .init())
        let url: URL = .init(fileURLWithPath: bundle.path(forResource: "VideoTest", ofType: "mov") ?? "")
        let avAssetMock: AVAsset = .init(url: url)
        let expectation = self.expectation(description: "error")
        // When
        mediaItem.type = .video(avAssetMock.duration.seconds)
        // Then
        service.fetchVideoAsset(for: mediaItem) { avAsset in
            XCTAssertEqual(avAssetMock.commonMetadata, avAsset?.commonMetadata, "is not equal metadata")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 4)
    }

    func testFetchAVAssetIsNotEqual() {
        // Given
        let mediaItem: MediaItem = .init(asset: .init())
        let url: URL = .init(fileURLWithPath: bundle.path(forResource: "VideoTest2", ofType: "mov") ?? "")
        let avAssetMock: AVAsset = .init(url: url)
        let expectation = self.expectation(description: "error")
        // When
        mediaItem.type = .video(avAssetMock.duration.seconds)
        // Then
        service.fetchVideoAsset(for: mediaItem) { avAsset in
            XCTAssertNotEqual(avAssetMock.metadata, avAsset?.metadata, "is equal metadata")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 4)
    }

    func testFetchAVAssetIsNil() {
        // Given
        let mediaItem: MediaItem = .init(asset: .init())
        let expectation = self.expectation(description: "error")
        // Then
        service.fetchVideoAsset(for: mediaItem) { avAsset in
            XCTAssertNil(avAsset, "is not nil")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 4)
    }

    func testFetchAVAssetLivePhoto() {
        // Given
        let mediaItem: MediaItem = .init(asset: .init())
        let expectation = self.expectation(description: "error")
        let videoURL: URL = .init(fileURLWithPath: bundle.path(forResource: "VideoTest", ofType: "mov") ?? "")
        let assetMock = AVURLAsset(url: videoURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        let avAssetMock = AVAsset(url: assetMock.url)
        // When
        mediaItem.type = .livePhoto
        // Then
        service.fetchVideoAsset(for: mediaItem) { avAsset in
            XCTAssertEqual(avAssetMock.commonMetadata, avAsset?.commonMetadata, "is not equal metadata")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 4)
    }

    func testFetchAVAssetLivePhotoIsNotEqual() {
        // Given
        let mediaItem: MediaItem = .init(asset: .init())
        let expectation = self.expectation(description: "error")
        let videoURL: URL = .init(fileURLWithPath: bundle.path(forResource: "VideoTest2", ofType: "mov") ?? "")
        let assetMock = AVURLAsset(url: videoURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        let avAssetMock = AVAsset(url: assetMock.url)
        // When
        mediaItem.type = .livePhoto
        // Then
        service.fetchVideoAsset(for: mediaItem) { avAsset in
            XCTAssertNotEqual(avAssetMock.commonMetadata, avAsset?.commonMetadata, "is equal metadata")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 4)
    }

    func testFetchAVAssetLivePhotoIsNil() {
        // Given
        let mediaItem: MediaItem = .init(asset: .init())
        let expectation = self.expectation(description: "error")
        // Then
        service.fetchVideoAsset(for: mediaItem) { avAsset in
            XCTAssertNil(avAsset?.commonMetadata, "is not nil")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 4)
    }

    static var allTests = [
        ("testPermissionAuthorizedStatus", testPermissionAuthorizedStatus)
    ]
}
