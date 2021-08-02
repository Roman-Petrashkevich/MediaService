//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import CollectionViewTools
import MediaService
import Photos

final class GalleryFactory {
    typealias Dependencies = HasMediaLibraryService
    private var dependencies: Dependencies

    init(dependencies: GalleryViewController.Dependencies) {
        self.dependencies = dependencies
    }

    func makeSectionItem(result: PHFetchResult<PHAsset>) -> [GeneralCollectionViewDiffSectionItem] {
        var cellItems: [GalleryCellItem] = []
        result.enumerateObjects { [weak self] asset, _, _ in
            guard let self = self else {
                return
            }
            let cellItem = GalleryCellItem(dependencies: self.dependencies, asset: asset)
            cellItems.append(cellItem)
        }

        let sectionItem = GeneralCollectionViewDiffSectionItem()
        sectionItem.cellItems = cellItems
        sectionItem.minimumInteritemSpacing = 0
        sectionItem.minimumLineSpacing = 3
        sectionItem.insets = .init(top: 0, left: 1.5, bottom: 0, right: 1.5)

        return [sectionItem]
    }
}
