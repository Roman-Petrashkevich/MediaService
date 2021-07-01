//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Framezilla
import CollectionViewTools
import MediaService
import Ion
import Photos

final class MainViewController: UIViewController {

    let mediaService = MediaLibraryServiceImp()

    private var mediaItemsCollections: [MediaItemsCollection] = []

    private lazy var collectionsCollector: Collector<[MediaItemsCollection]> = {
        return .init(source: mediaService.collectionsEventSource)
    }()

    private lazy var permissionStatusCollector: Collector<PHAuthorizationStatus> = {
        return .init(source: mediaService.permissionStatusEventSource)
    }()

    private lazy var collectionViewManager: CollectionViewManager = .init(collectionView: collectionView)
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    private lazy var mainFactory: MainFactory = .init(output: self, mediaService: mediaService)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Album"
        navigationController?.navigationBar.backgroundColor = .white
        view.addSubview(collectionView)
        view.backgroundColor = .black
        mediaService.requestMediaLibraryPermissions()
        permissionStatusEventTriggered()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.configureFrame { maker in
            maker.left().right().bottom(to: view.nui_safeArea.bottom).top(to: view.nui_safeArea.top)
        }
    }

    func selectAlbumEventTriggered(with mediaItemCollection: MediaItemsCollection) {
        let galleryViewController = GalleryViewController(mediaService: mediaService, mediaItemCollection: mediaItemCollection)
        navigationController?.pushViewController(galleryViewController, animated: true)
    }

    private func permissionStatusEventTriggered() {
        permissionStatusCollector.subscribe { [weak self] status in
            switch status {
            case .authorized, .limited:
                self?.mediaService.fetchMediaItemCollections()
                self?.collectionsCollectorEventTriggered()
            case .notDetermined, .denied, .restricted:
                self?.mediaService.requestMediaLibraryPermissions()
            default:
                 break
            }
        }
    }

    private func collectionsCollectorEventTriggered() {
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
