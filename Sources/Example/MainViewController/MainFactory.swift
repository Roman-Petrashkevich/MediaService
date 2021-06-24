//
//  MainFactory.swift
//  Example
//
//  Created by Evgeny Schwarzkopf on 11.04.2021.
//

import CollectionViewTools
import MediaService

final class MainFactory {

    private weak var output: MainViewController?
    private var mediaService: MediaLibraryServiceImp

    init(output: MainViewController?, mediaService: MediaLibraryServiceImp) {
        self.output = output
        self.mediaService = mediaService
    }

    func makeSectionItem(mediaItemsCollections: [MediaItemCollection]) -> [GeneralCollectionViewDiffSectionItem] {
        let cellItems = mediaItemsCollections.map { mediaItemsCollection in
            makeCellItem(mediaItemsCollection: mediaItemsCollection)
        }

        let sectionItem = GeneralCollectionViewDiffSectionItem()
        sectionItem.cellItems = cellItems
        sectionItem.minimumLineSpacing = 10
        sectionItem.minimumInteritemSpacing = 10
        return [sectionItem]
    }

    private func makeCellItem(mediaItemsCollection: MediaItemCollection) -> MainCellItem {
        let cellItem = MainCellItem(mediaItemCollection: mediaItemsCollection, mediaService: mediaService)

        cellItem.itemDidSelectHandler = { [weak self] _ in
            self?.output?.selectAlbumEventTriggered(with: mediaItemsCollection)
        }

        return cellItem
    }
}
