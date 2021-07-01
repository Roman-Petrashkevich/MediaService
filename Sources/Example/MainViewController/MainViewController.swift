//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Framezilla
import CollectionViewTools
import MediaService
import Ion
import Photos

final class MainViewController: UIViewController {

    typealias Dependencies = HasMediaLibraryService

    let dependencies: Dependencies

    private var mediaItemsCollections: [MediaItemsCollection] = []

    private lazy var collectionsCollector: Collector<[MediaItemsCollection]> = {
        return .init(source: dependencies.mediaLibraryService.collectionsEventSource)
    }()

    private lazy var permissionStatusCollector: Collector<PHAuthorizationStatus> = {
        return .init(source: dependencies.mediaLibraryService.permissionStatusEventSource)
    }()

    private lazy var collectionViewManager: CollectionViewManager = .init(collectionView: collectionView)
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    private lazy var mainFactory: MainFactory = .init(output: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Album"
        navigationController?.navigationBar.backgroundColor = .white
        view.addSubview(collectionView)
        view.backgroundColor = .black
        dependencies.mediaLibraryService.requestMediaLibraryPermissions()
        subscribeForPermissionStatus()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.configureFrame { maker in
            maker.left().right().bottom(to: view.nui_safeArea.bottom).top(to: view.nui_safeArea.top)
        }
    }

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func selectAlbumEventTriggered(with mediaItemCollection: MediaItemsCollection) {
        let galleryViewController = GalleryViewController(dependencies: dependencies, mediaItemCollection: mediaItemCollection)
        navigationController?.pushViewController(galleryViewController, animated: true)
    }

    func loadThumbnailCollection(_ mediaItemCollection: MediaItemsCollection,
                                 completion: @escaping (UIImage?) -> Void) {
        dependencies.mediaLibraryService.fetchThumbnail(for: mediaItemCollection,
                                                        size: .zero,
                                                        contentMode: .aspectFill,
                                                        completion: completion)
    }

    private func subscribeForPermissionStatus() {
        permissionStatusCollector.subscribe { [weak self] status in
            switch status {
            case .authorized, .limited:
                self?.dependencies.mediaLibraryService.fetchMediaItemCollections()
                self?.subscribeForCollections()
            case .notDetermined, .denied, .restricted:
                self?.dependencies.mediaLibraryService.requestMediaLibraryPermissions()
            default:
                 break
            }
        }
    }

    private func subscribeForCollections() {
        collectionsCollector.subscribe { [weak self] (mediaItemsCollections: [MediaItemsCollection]) in
            self?.mediaItemsCollections = mediaItemsCollections
            self?.updateCollectionManager()
        }
    }

    private func updateCollectionManager() {
        let sectionItem = mainFactory.makeSectionItem(mediaItemsCollections: mediaItemsCollections)
        collectionViewManager.update(with: sectionItem, animated: true)
    }
}
