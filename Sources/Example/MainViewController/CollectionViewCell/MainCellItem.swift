//
//  MainCellItem.swift
//  Example
//
//  Created by Evgeny Schwarzkopf on 11.04.2021.
//

import CollectionViewTools
import MediaService

final class MainCellItem: CollectionViewDiffCellItem {

    typealias Cell = MainCollectionViewCell
    private(set) var reuseType: ReuseType = .class(Cell.self)
    var diffIdentifier: String {
        mediaItemCollection.identifier
    }

    private let mediaItemCollection: MediaItemsCollection
    private let mediaService: MediaLibraryServiceImp

    init(mediaItemCollection: MediaItemsCollection, mediaService: MediaLibraryServiceImp) {
        self.mediaItemCollection = mediaItemCollection
        self.mediaService = mediaService
    }

    func isEqual(to item: DiffItem) -> Bool {
        guard let item = item as? MainCellItem else {
            return false
        }
        return mediaItemCollection.identifier == item.mediaItemCollection.identifier
    }

    func configure(_ cell: UICollectionViewCell) {
        guard let cell = cell as? Cell else {
            return
        }

        cell.titleLabel.text = mediaItemCollection.title

        mediaService.fetchThumbnail(for: mediaItemCollection, size: .zero, contentMode: .aspectFill) { image in
            if image != nil {
                cell.imageView.image = image
            }
            else {
                cell.imageView.image = UIImage(systemName: "photo.on.rectangle.angled")
                cell.imageView.tintColor = .black
            }
        }
    }

    func size(in collectionView: UICollectionView, sectionItem: CollectionViewSectionItem) -> CGSize {
        .init(width: collectionView.bounds.width / 2, height: collectionView.bounds.width / 2)
    }
}
