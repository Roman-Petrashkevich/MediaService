//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import CollectionViewTools
import MediaService
import Photos

final class GalleryFactory {

    private weak var output: GalleryViewController?

    init(output: GalleryViewController?) {
        self.output = output
    }

    func makeSectionItem(result: PHFetchResult<PHAsset>) -> [GeneralCollectionViewDiffSectionItem] {
        var cellItems: [GalleryCellItem] = []
        result.enumerateObjects { [weak self] asset, _, _ in
            guard let self = self else {
                return
            }
            let mediaItem = MediaItem(asset: asset)
            let cellItem = GalleryCellItem(mediaItem: mediaItem)
            self.output?.loadThumbnailMediaItem(mediaItem) { image in
                cellItem.loadThumbnailEventHandler?(image)
            }
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
