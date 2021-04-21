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
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
