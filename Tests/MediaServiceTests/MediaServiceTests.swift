import XCTest
@testable import MediaService
import Ion
import Photos

final class MediaServiceTests: XCTestCase {

    private lazy var fetchCollectionsServiceMock = FetchCollectionServiceMock()
    private lazy var permissionsServiceMock = PermissionsServiceMock()
    private lazy var thumbnailCacheServiceMock = ThumbnailCacheServiceMock()

    lazy var service: MediaLibraryService = {
        let service = MediaLibraryServiceImp(fetchCollectionsService: fetchCollectionsServiceMock,
                                             permissionsService: permissionsServiceMock,
                                             thumbnailCacheService: thumbnailCacheServiceMock)
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

    //MARK: - FetchMediaItemsResultTest

    func testFetchMediaItemsResultWithFilterAll() {
        //Given
        let mediaItemCollectionsMock: MediaItemCollection = .init(identifier: "12", title: "Recents")
        let filter: MediaItemFilter = .all
        let expectation = self.expectation(description: "error")

        //When
        service.fetchMediaItems(in: mediaItemCollectionsMock, filter: .all)

        //Then
        mediaItemResultCollector.subscribe { mediaResult in
            XCTAssertEqual(mediaItemCollectionsMock.identifier, mediaResult.collection.identifier, "is not equal identifier")
            XCTAssertEqual(filter, mediaResult.filter, "is not equal filter")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }

    func testFetchMediaItemsResultWithFilterVideo() {
        //Given
        let mediaItemCollectionsMock: MediaItemCollection = .init(identifier: "12", title: "Recents")
        let filter: MediaItemFilter = .video
        let expectation = self.expectation(description: "error")

        //When
        service.fetchMediaItems(in: mediaItemCollectionsMock, filter: .video)

        //Then
        mediaItemResultCollector.subscribe { mediaResult in
            XCTAssertEqual(mediaItemCollectionsMock.identifier, mediaResult.collection.identifier, "is not equal identifier")
            XCTAssertEqual(filter, mediaResult.filter, "is not equal filter")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
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

    func testFetchMediaItemThumbnailFromCache() {
        //Given
        let asset = PHAsset()
        let mediaItem: MediaItem = .init(asset: asset)
        let pencilImage = UIImage(systemName: "pencil")
        let expectation = self.expectation(description: "error")
        thumbnailCacheServiceMock.thumbnailCache.removeAllObjects()

        //When
        thumbnailCacheServiceMock.thumbnailCache.setObject(pencilImage ?? .add, forKey: asset.localIdentifier as NSString)

        //Then
        service.fetchThumbnail(for: mediaItem, size: mediaItem.thumbnail?.size ?? .zero, contentMode: .aspectFill) { image in
            XCTAssertEqual(mediaItem.thumbnail, image, "is not equal image")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }

    func testFetchMediaItemThumbnailNil() {
        // Given
        let mediaItem: MediaItem = .dummy
        let expectation = self.expectation(description: "error")

        //Then
        service.fetchThumbnail(for: mediaItem, size: .zero, contentMode: .aspectFill) { image in
            XCTAssertEqual(mediaItem.thumbnail, image, "is not equal image")
            XCTAssertNil(image, "is not equal nil")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }

    // MARK: - FethcMediaCollectionThumbnailTest

    func testFetchMediaCollectionThumbnail() {
        // Given
        let mediaItemCollectionsMock: MediaItemCollection = .init(identifier: "12", title: "Recents")
        let pencilImage = UIImage(systemName: "pencil")
        mediaItemCollectionsMock.thumbnail = pencilImage
        let expectation = self.expectation(description: "error")

        //Then
        service.fetchThumbnail(for: mediaItemCollectionsMock, size: pencilImage?.size ?? .zero, contentMode: .aspectFill) { image in
            XCTAssertEqual(mediaItemCollectionsMock.thumbnail, image, "is not equal image")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
    }

    func testFetchMediaCollectionThumbnailNil() {
        // Given
        let mediaItemCollectionsMock: MediaItemCollection = .init(identifier: "12", title: "Recents")
        let expectation = self.expectation(description: "error")

        //Then
        service.fetchThumbnail(for: mediaItemCollectionsMock, size: .zero, contentMode: .aspectFill) { image in
            XCTAssertEqual(mediaItemCollectionsMock.thumbnail, image, "is not equal image")
            XCTAssertNil(image, "is not equal nil")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.2)
    }

    static var allTests = [
        ("testPermissionAuthorizedStatus", testPermissionAuthorizedStatus)
    ]
}
