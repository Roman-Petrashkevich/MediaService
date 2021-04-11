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

    func makeSectionItem(mediaItemsCollection: [MediaItemCollection]) -> [GeneralCollectionViewDiffSectionItem] {
        let cellItem = mediaItemsCollection.map { mediaItemsCollection in
            makeCellItem(mediaItemsCollection: mediaItemsCollection)
        }

        let sectionItem = GeneralCollectionViewDiffSectionItem()
        sectionItem.cellItems = cellItem
        sectionItem.minimumLineSpacing = 10
        sectionItem.minimumInteritemSpacing = 10
        return [sectionItem]
    }

    private func makeCellItem(mediaItemsCollection: MediaItemCollection) -> MainCellItem {
        let cellItem = MainCellItem(mediaItemCollection: mediaItemsCollection, mediaService: mediaService)

        cellItem.itemDidSelectHandler = { [weak self] _ in
            self?.output?.displayGalleryEventTriggered(with: mediaItemsCollection)
        }

        return cellItem
    }
}
