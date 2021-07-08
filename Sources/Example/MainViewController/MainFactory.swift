//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import CollectionViewTools
import MediaService

final class MainFactory {

    private weak var viewController: MainViewController?

    init(viewController: MainViewController?) {
        self.viewController = viewController
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

        viewController?.loadThumbnailCollection(mediaItemsCollection) { image in
            cellItem.loadThumbnailEventHandler?(image)
        }

        cellItem.itemDidSelectHandler = { [weak self] _ in
            self?.viewController?.selectAlbumEventTriggered(with: mediaItemsCollection)
        }

        return cellItem
    }
}
