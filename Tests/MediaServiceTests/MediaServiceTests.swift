import XCTest
@testable import MediaService
import Ion
import Photos

final class MediaServiceTests: XCTestCase {

    private lazy var fetchCollectionsServiceMock = FetchCollectionServiceMock()
    private lazy var permissionsServiceMock = PermissionsServiceMock()
    private lazy var thumbnailCacheServiceMock = ThumbnailCacheServiceMock()
    private lazy var fetchAssetServiceMock = FetchAssetsServiceMock()
    private lazy var cachingImageManagerMock = CachingImageManagerMock()
    private lazy var assetResourceManagerMock = AssetResourceManagerMock()

    private var bundle: Bundle {
        Bundle(for: Self.self)
    }

    lazy var service: MediaLibraryService = {
        let service = MediaLibraryServiceImp(fetchCollectionsService: fetchCollectionsServiceMock,
                                             permissionsService: permissionsServiceMock,
                                             fetchAssetsService: fetchAssetServiceMock,
                                             thumbnailCacheService: thumbnailCacheServiceMock,
                                             cachingImageManager: cachingImageManagerMock,
                                             assetResourceManager: assetResourceManagerMock)
        return service
    }()

    private lazy var permissionStatusCollector: Collector<PHAuthorizationStatus> = {
        return .init(source: service.permissionStatusEventSource)
    }()

    private lazy var mediaItemCollectionsCollector: Collector<[MediaItemCollection]> = {
        return .init(source: service.collectionsEventSource)
    }()

    private lazy var mediaItemResultCollector: Collector<MediaItemFetchResult> = {
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
        //Given
        let authStatus: PHAuthorizationStatus = .authorized
        let expectation = self.expectation(description: "error")

        //When
        permissionsServiceMock.status = .authorized
        service.requestMediaLibraryPermissions()

        //Then
        permissionStatusCollector.subscribe { status in
            XCTAssertEqual(status, authStatus, "Permission status is not equal")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }

    func testPermissionDeniedStatus() {
        //Given
        let authStatus: PHAuthorizationStatus = .denied
        let expectation = self.expectation(description: "error")

        //When
        permissionsServiceMock.status = .denied
        service.requestMediaLibraryPermissions()

        //Then
        permissionStatusCollector.subscribe { status in
            XCTAssertEqual(status, authStatus, "Permission status is not equal")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }

    func testPermissionNotDeterminedStatus() {
        //Given
        let authStatus: PHAuthorizationStatus = .notDetermined
        let expectation = self.expectation(description: "error")

        //When
        permissionsServiceMock.status = .notDetermined
        service.requestMediaLibraryPermissions()

        //Then
        permissionStatusCollector.subscribe { status in
            XCTAssertEqual(status, authStatus, "Permission status is not equal")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }

    func testPermissionRestrictedStatus() {
        //Given
        let authStatus: PHAuthorizationStatus = .restricted
        let expectation = self.expectation(description: "error")

        //When
        permissionsServiceMock.status = .restricted
        service.requestMediaLibraryPermissions()

        //Then
        permissionStatusCollector.subscribe { status in
            XCTAssertEqual(status, authStatus, "Permission status is not equal")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }

    func testPermissionLimitedStatus() {
        if #available(iOS 14, *) {
            //Given
            let authStatus: PHAuthorizationStatus = .limited
            let expectation = self.expectation(description: "error")

            //When
            permissionsServiceMock.status = .limited
            service.requestMediaLibraryPermissions()

            //Then
            permissionStatusCollector.subscribe { status in
                XCTAssertEqual(status, authStatus, "Permission status is not equal")
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 0.1)
        }
    }

    func testPermissionAuthorizedStatusIsNotEqual() {
        //Given
        let authStatus: PHAuthorizationStatus = .authorized
        let expectation = self.expectation(description: "error")

        //When
        permissionsServiceMock.status = .notDetermined
        service.requestMediaLibraryPermissions()

        //Then
        permissionStatusCollector.subscribe { status in
            XCTAssertNotEqual(status, authStatus, "Permission status is equal")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }

    // MARK: - FetchMediaItemCollectorTest

    func testFetchMediaItemCollectionsCollector() {
        //Given
        let mediaItemCollectionsMock: [MediaItemCollection] = [
            .init(identifier: "12", title: "Recents")]
        let expectation = self.expectation(description: "error")

        //When
        service.fetchMediaItemCollections()

        //Then
        mediaItemCollectionsCollector.subscribe { mediaItemCollections in
            XCTAssertEqual(mediaItemCollectionsMock.first?.identifier, mediaItemCollections.first?.identifier, "is not equal identifier")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }

    // MARK: - FetchMediaItemsResultTest

    func testFetchMediaItemsResultWithFilterAll() {
        //Given
        let mediaItemCollectionsMock: MediaItemCollection = .init(identifier: "12", title: "Recents")
        let mediaTypes: [PHAssetMediaType] = [.video, .image, .image]
        let expectation = self.expectation(description: "error")

        //When
        service.fetchMediaItems(in: mediaItemCollectionsMock, filter: .all)
        fetchCollectionsServiceMock.assets = [.init(), .init(), .init()]

        //Then
        mediaItemResultCollector.subscribe { mediaResult in
            mediaResult.fetchResult.enumerateObjects { _, index, _ in
                XCTAssertEqual(mediaTypes[index], mediaResult.fetchResult.mediaType(index), "is not equal media type")
            }
            XCTAssertEqual(mediaTypes.count, mediaResult.fetchResult.count, "is not equal count")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
    }

    func testFetchMediaItemsResultWithFilterVideo() {
        //Given
        let mediaItemCollectionsMock: MediaItemCollection = .init(identifier: "12", title: "Recents")
        let mediaTypes: [PHAssetMediaType] = [.video]
        let expectation = self.expectation(description: "error")

        //When
        service.fetchMediaItems(in: mediaItemCollectionsMock, filter: .video)
        fetchCollectionsServiceMock.assets = [.init()]

        //Then
        mediaItemResultCollector.subscribe { mediaResult in
            mediaResult.fetchResult.enumerateObjects { _, index, _ in
                XCTAssertEqual(mediaTypes[index], mediaResult.fetchResult.mediaType(index), "is not equal media type")
            }
            XCTAssertEqual(mediaTypes.count, mediaResult.fetchResult.count, "is not equal count")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
    }

    // MARK: - FetchMediaItemThumbnailTest

    func testFetchMediaItemThumbnail() {
        // Given
        let mediaItem: MediaItem = .init(asset: .init())
        let pencilImage = UIImage(systemName: "pencil")
        mediaItem.thumbnail = pencilImage
        let expectation = self.expectation(description: "error")

        //Then
        service.fetchThumbnail(for: mediaItem, size: mediaItem.thumbnail?.size ?? .zero, contentMode: .aspectFill) { image in
            XCTAssertEqual(mediaItem.thumbnail, image, "is not equal image")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }

    func testFetchMediaItemThumbnailIsNil() {
        // Given
        let mediaItem: MediaItem = .dummy
        let expectation = self.expectation(description: "error")

        //When
        fetchAssetServiceMock.makeAsset = nil
        thumbnailCacheServiceMock.thumbnailCache.removeAllObjects()

        //Then
        service.fetchThumbnail(for: mediaItem, size: .zero, contentMode: .aspectFill) { image in
            XCTAssertNil(image, "is not nil")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    func testFetchMediaItemThumbnailFromCache() {
        //Given
        let mediaItem: MediaItem = .dummy
        let pencilImage = UIImage(systemName: "pencil")
        let expectation = self.expectation(description: "error")

        //When
        let key = fetchAssetServiceMock.fetchAsset?.localIdentifier ?? ""
        thumbnailCacheServiceMock.thumbnailCache.removeAllObjects()
        thumbnailCacheServiceMock.thumbnailCache.setObject(pencilImage ?? UIImage(),
                                                           forKey: key as NSString)

        //Then
        service.fetchThumbnail(for: mediaItem, size: .zero, contentMode: .aspectFill) { image in
            XCTAssertEqual(pencilImage, image, "is not equal image")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
    }

    // MARK: - FethcMediaCollectionThumbnailTest

    func testFetchMediaCollectionThumbnail() {
        // Given
        let mediaItemCollections: MediaItemCollection = .init(identifier: "12", title: "Recents")
        let pencilImage = UIImage(systemName: "pencil")
        mediaItemCollections.thumbnail = pencilImage
        let expectation = self.expectation(description: "error")

        //Then
        service.fetchThumbnail(for: mediaItemCollections, size: pencilImage?.size ?? .zero, contentMode: .aspectFill) { image in
            XCTAssertEqual(mediaItemCollections.thumbnail, image, "is not equal image")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
    }

    func testFetchMediaCollectionThumbnailFromCache() {
        // Given
        let mediaItemCollection: MediaItemCollection = .init(identifier: "12", title: "Recents")
        let pencilImage = UIImage(systemName: "pencil")
        let expectation = self.expectation(description: "error")

        //When
        let key = fetchAssetServiceMock.fetchAsset?.localIdentifier ?? ""
        thumbnailCacheServiceMock.thumbnailCache.removeAllObjects()
        thumbnailCacheServiceMock.thumbnailCache.setObject(pencilImage ?? UIImage(),
                                                           forKey: key as NSString)

        //Then
        service.fetchThumbnail(for: mediaItemCollection, size: .zero, contentMode: .aspectFill) { image in
            XCTAssertEqual(pencilImage, image, "is not equal image")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
    }

    func testFetchImage() {
        // Given
        let mediaItem: MediaItem = .init(asset: .init())
        let pencilData = UIImage(systemName: "pencil")?.pngData() ?? .init()
        let pencilImage = UIImage(data: pencilData)
        let expectation = self.expectation(description: "error")

        //When
        cachingImageManagerMock.pencilData = pencilData

        //Then
        service.fetchImage(for: mediaItem) { image in
            XCTAssertEqual(pencilImage?.pngData(), image?.pngData(), "is not equal image")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }

    func testFetchImageIsNotEqual() {
        // Given
        let mediaItem: MediaItem = .init(asset: .init())
        let pencilData = UIImage(systemName: "pencil")?.pngData() ?? .init()
        let pencilImage = UIImage(systemName: "pencil")
        let expectation = self.expectation(description: "error")

        //When
        cachingImageManagerMock.pencilData = pencilData

        //Then
        service.fetchImage(for: mediaItem) { image in
            XCTAssertNotEqual(pencilImage?.pngData(), image?.pngData(), "is equal image")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }

    func testFetchImageNil() {
        // Given
        let mediaItem: MediaItem = .init(asset: .init())
        let expectation = self.expectation(description: "error")

        //When
        cachingImageManagerMock.pencilData = nil

        //Then
        service.fetchImage(for: mediaItem) { image in
            XCTAssertNil(image, "is not nil")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }

    func testFetchAVAssetWithVideo() {
        // Given
        let mediaItem: MediaItem = .init(asset: .init())
        let url: URL = .init(fileURLWithPath: bundle.path(forResource: "VideoTest", ofType: "mov") ?? "")
        let avAssetMock: AVAsset = .init(url: url)
        let expectation = self.expectation(description: "error")

        //When
        mediaItem.type = .video(avAssetMock.duration.seconds)

        //Then
        service.fetchVideoAsset(for: mediaItem) { avAsset in
            XCTAssertEqual(avAssetMock.commonMetadata, avAsset?.commonMetadata, "is not equal metadata")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }

    func testFetchAVAssetIsNotEqual() {
        // Given
        let mediaItem: MediaItem = .init(asset: .init())
        let url: URL = .init(fileURLWithPath: bundle.path(forResource: "VideoTest2", ofType: "mov") ?? "")
        let avAssetMock: AVAsset = .init(url: url)
        let expectation = self.expectation(description: "error")

        //When
        mediaItem.type = .video(avAssetMock.duration.seconds)

        //Then
        service.fetchVideoAsset(for: mediaItem) { avAsset in
            XCTAssertNotEqual(avAssetMock.metadata, avAsset?.metadata, "is equal metadata")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }

    func testFetchAVAssetIsNil() {
        // Given
        let mediaItem: MediaItem = .init(asset: .init())
        let expectation = self.expectation(description: "error")

        //Then
        service.fetchVideoAsset(for: mediaItem) { avAsset in
            XCTAssertNil(avAsset, "is not nil")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }

    func testFetchAVAssetLivePhoto() {
        // Given
        let mediaItem: MediaItem = .init(asset: .init())
        let expectation = self.expectation(description: "error")
        let videoURL: URL = .init(fileURLWithPath: bundle.path(forResource: "VideoTest", ofType: "mov") ?? "")
        let assetMock = AVURLAsset(url: videoURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        let avAssetMock = AVAsset(url: assetMock.url)

        //When
        mediaItem.type = .livePhoto

        //Then
        service.fetchVideoAsset(for: mediaItem) { avAsset in
            XCTAssertEqual(avAssetMock.commonMetadata, avAsset?.commonMetadata, "is not equal metadata")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
    }

    func testFetchAVAssetLivePhotoIsNotEqual() {
        // Given
        let mediaItem: MediaItem = .init(asset: .init())
        let expectation = self.expectation(description: "error")
        let videoURL: URL = .init(fileURLWithPath: bundle.path(forResource: "VideoTest2", ofType: "mov") ?? "")
        let assetMock = AVURLAsset(url: videoURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        let avAssetMock = AVAsset(url: assetMock.url)

        //When
        mediaItem.type = .livePhoto

        //Then
        service.fetchVideoAsset(for: mediaItem) { avAsset in
            XCTAssertNotEqual(avAssetMock.commonMetadata, avAsset?.commonMetadata, "is equal metadata")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
    }

    func testFetchAVAssetLivePhotoIsNil() {
        // Given
        let mediaItem: MediaItem = .init(asset: .init())
        let expectation = self.expectation(description: "error")

        //Then
        service.fetchVideoAsset(for: mediaItem) { avAsset in
            XCTAssertNil(avAsset?.commonMetadata, "is not nil")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
    }

    static var allTests = [
        ("testPermissionAuthorizedStatus", testPermissionAuthorizedStatus)
    ]
}
