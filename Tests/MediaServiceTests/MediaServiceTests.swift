import XCTest
@testable import MediaService
import Ion
import Photos

final class MediaServiceTests: XCTestCase {

    lazy var service: MediaLibraryService = {
        let service = MediaLibraryServiceImp()
        service.mediaLibraryServiceTest = MediaLibraryServiceTestMock()
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

    func testPermissionAuthorizedStatus() {
        //Given
        let authStatus: PHAuthorizationStatus = .authorized
        let expectation = self.expectation(description: "error")

        //When
        MediaLibraryServiceTestMock.status = .authorized
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
        MediaLibraryServiceTestMock.status = .denied
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
        MediaLibraryServiceTestMock.status = .notDetermined
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
        MediaLibraryServiceTestMock.status = .restricted
        service.requestMediaLibraryPermissions()

        //Then
        permissionStatusCollector.subscribe { status in
            XCTAssertEqual(status, authStatus, "Permission status is not equal")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }

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

    func testFetchMediaItemsResultCollector() {
        //Given
        let mediaItemCollectionsMock: MediaItemCollection = .init(identifier: "12", title: "Recents")
        let expectation = self.expectation(description: "error")

        //When
        service.fetchMediaItems(in: mediaItemCollectionsMock, filter: .all)

        //Then
        mediaItemResultCollector.subscribe { mediaResult in
            XCTAssertEqual(mediaItemCollectionsMock.identifier, mediaResult.collection.identifier, "is not equal identifier")
            XCTAssertEqual(mediaItemCollectionsMock.title, mediaResult.collection.title, "is not equal identifier")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }

    func testFetchThumbnailItem() {
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

    func testFetchThumbnailCollection() {
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

    static var allTests = [
        ("testPermissionAuthorizedStatus", testPermissionAuthorizedStatus)
    ]
}
