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

    private let mediaService: MediaLibraryServiceImp
    private let mediaItemCollection: MediaItemsCollection

    private lazy var mediaItemResultCollector: Collector<MediaItemsFetchResult> = {
        return .init(source: mediaService.mediaItemsEventSource)
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
    private lazy var galleryFactory: GalleryFactory = .init(output: self, mediaService: mediaService)

    init(mediaService: MediaLibraryServiceImp, mediaItemCollection: MediaItemsCollection) {
        self.mediaService = mediaService
        self.mediaItemCollection = mediaItemCollection
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.mediaService = MediaLibraryServiceImp()
        self.mediaItemCollection = .init(collection: .init())
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = mediaItemCollection.title
        view.addSubview(collectionView)
        view.backgroundColor = .black
        mediaService.fetchMediaItems(in: mediaItemCollection)
        resultCollectorEventTriggered()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.configureFrame { maker in
            maker.left().right().bottom(to: view.nui_safeArea.bottom).top(to: view.nui_safeArea.top)
        }
    }

    private func resultCollectorEventTriggered() {
        mediaItemResultCollector.subscribe { [weak self] mediaItemFetchResult in
            self?.updateCollectionManager(with: mediaItemFetchResult.fetchResult)
        }
    }

    private func updateCollectionManager(with result: PHFetchResult<PHAsset>) {
        let sectionItem = galleryFactory.makeSectionItem(result: result)
        collectionViewManager.update(with: sectionItem, animated: true)
    }
}
