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

    init(output: MainViewController?) {
        self.output = output
    }

    func makeSectionItem(mediaItemsCollections: [MediaItemsCollection]) -> [GeneralCollectionViewDiffSectionItem] {
        let cellItems = mediaItemsCollections.map { mediaItemsCollection in
            makeCellItem(mediaItemsCollection: mediaItemsCollection)
        }

        let sectionItem = GeneralCollectionViewDiffSectionItem()
        sectionItem.cellItems = cellItems
        sectionItem.minimumLineSpacing = 10
        sectionItem.minimumInteritemSpacing = 10
        return [sectionItem]
    }

    private func makeCellItem(mediaItemsCollection: MediaItemsCollection) -> MainCellItem {
        let cellItem = MainCellItem(mediaItemCollection: mediaItemsCollection)

        output?.loadThumbnailCollection(mediaItemsCollection) { image in
            cellItem.loadThumbnailEventHandler?(image)
        }

        cellItem.itemDidSelectHandler = { [weak self] _ in
            self?.output?.selectAlbumEventTriggered(with: mediaItemsCollection)
        }

        return cellItem
    }
}
