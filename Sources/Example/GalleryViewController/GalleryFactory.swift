//
//  GalleryFactory.swift
//  Example
//
//  Created by Evgeny Schwarzkopf on 11.04.2021.
//

import CollectionViewTools
import MediaService
import Photos

final class GalleryFactory {

    private weak var output: GalleryViewController?
    private var mediaService: MediaLibraryServiceImp

    init(output: GalleryViewController?, mediaService: MediaLibraryServiceImp) {
        self.output = output
        self.mediaService = mediaService
    }

    func makeSectionItem(result: PHFetchResult<PHAsset>) -> [GeneralCollectionViewDiffSectionItem] {
        var cellItems: [GalleryCellItem] = []
        result.enumerateObjects { [weak self] asset, _, _ in
            guard let self = self else {
                return
            }
            cellItems.append(.init(mediaService: self.mediaService, asset: asset))
        }

        let sectionItem = GeneralCollectionViewDiffSectionItem()
        sectionItem.cellItems = cellItems
        sectionItem.minimumInteritemSpacing = 0
        sectionItem.minimumLineSpacing = 3
        sectionItem.insets = .init(top: 0, left: 1.5, bottom: 0, right: 1.5)

        return [sectionItem]
    }
}
