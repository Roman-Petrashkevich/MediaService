//
//  GalleryFactory.swift
//  Example
//
//  Created by Evgeny Schwarzkopf on 11.04.2021.
//

import CollectionViewTools
import MediaService

final class GalleryFactory {

    private weak var output: GalleryViewController?
    private var mediaService: MediaLibraryServiceImp

    init(output: GalleryViewController?, mediaService: MediaLibraryServiceImp) {
        self.output = output
        self.mediaService = mediaService
    }

    func makeSectionItem(mediaItems: [MediaItem]) -> [GeneralCollectionViewDiffSectionItem] {
        let cellItems = mediaItems.map { mediaItem in
            GalleryCellItem(mediaService: mediaService, mediaItem: mediaItem)
        }

        let sectionItem = GeneralCollectionViewDiffSectionItem()
        sectionItem.cellItems = cellItems
        sectionItem.minimumInteritemSpacing = 0
        sectionItem.minimumLineSpacing = 3
        sectionItem.insets = .init(top: 0, left: 1.5, bottom: 0, right: 1.5)

        return [sectionItem]
    }
}
