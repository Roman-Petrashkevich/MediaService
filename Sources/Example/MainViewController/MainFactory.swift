//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import CollectionViewTools
import MediaService

final class MainFactory {

    typealias Dependencies = HasMediaLibraryService

    private let dependencies: Dependencies
    private weak var output: MainViewOutput?

    init(dependencies: Dependencies, output: MainViewOutput) {
        self.dependencies = dependencies
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
        let cellItem = MainCellItem(dependencies: dependencies, mediaItemCollection: mediaItemsCollection)

        cellItem.itemDidSelectHandler = { [weak self] _ in
            self?.output?.selectAlbumEventTriggered(with: mediaItemsCollection)
        }

        return cellItem
    }
}
