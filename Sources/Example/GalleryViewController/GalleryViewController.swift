//
//  GalleryViewController.swift
//  Example
//
//  Created by Evgeny Schwarzkopf on 11.04.2021.
//

import Framezilla
import MediaService
import Ion
import Photos
import CollectionViewTools

final class GalleryViewController: UIViewController {

    typealias Dependencies = HasMediaLibraryService

    let dependencies: Dependencies

    private let mediaItemCollection: MediaItemsCollection

    private lazy var mediaItemResultCollector: Collector<MediaItemsFetchResult> = {
        return .init(source: dependencies.mediaLibraryService.mediaItemsEventSource)
    }()

    private lazy var collectionViewManager: CollectionViewManager = .init(collectionView: collectionView)
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .never
        return collectionView
    }()
    private lazy var galleryFactory: GalleryFactory = .init(output: self)

    init(dependencies: Dependencies, mediaItemCollection: MediaItemsCollection) {
        self.dependencies = dependencies
        self.mediaItemCollection = mediaItemCollection
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = mediaItemCollection.title
        view.addSubview(collectionView)
        view.backgroundColor = .black
        dependencies.mediaLibraryService.fetchMediaItems(in: mediaItemCollection, filter: .all)
        subscribeForMediaItemsResult()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.configureFrame { maker in
            maker.left().right().bottom(to: view.nui_safeArea.bottom).top(to: view.nui_safeArea.top)
        }
    }

    func loadThumbnailMediaItem(_ mediaItem: MediaItem,
                                completion: @escaping (UIImage?) -> Void) {
        dependencies.mediaLibraryService.fetchThumbnail(for: mediaItem,
                                                        size: .zero,
                                                        contentMode: .aspectFill,
                                                        completion: completion)
    }

    private func subscribeForMediaItemsResult() {
        mediaItemResultCollector.subscribe { [weak self] mediaItemFetchResult in
            self?.updateCollectionManager(with: mediaItemFetchResult.fetchResult)
        }
    }

    private func updateCollectionManager(with result: PHFetchResult<PHAsset>) {
        let sectionItem = galleryFactory.makeSectionItem(result: result)
        collectionViewManager.update(with: sectionItem, animated: true)
    }
}
