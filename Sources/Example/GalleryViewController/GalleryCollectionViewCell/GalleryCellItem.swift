//
//  GalleryCellItem.swift
//  Example
//
//  Created by Evgeny Schwarzkopf on 11.04.2021.
//

import CollectionViewTools
import Photos
import MediaService

final class GalleryCellItem: CollectionViewDiffCellItem {
    typealias Cell = GalleryCollectionViewCell

    private(set) var reuseType: ReuseType = .class(Cell.self)
    var diffIdentifier: String {
        ""
    }

    private let mediaService: MediaLibraryServiceImp
    private let mediaItem: MediaItem
    private let internalInset: CGFloat = 1.5
    private let numberOfRows: Int = 3

    init(mediaService: MediaLibraryServiceImp, asset: PHAsset) {
        self.mediaService = mediaService
        self.mediaItem = .init(asset: asset)
    }

    func isEqual(to item: DiffItem) -> Bool {
        guard let item = item as? GalleryCellItem else {
            return false
        }
        return mediaItem == item.mediaItem
    }

    func configure(_ cell: UICollectionViewCell) {
        guard let cell = cell as? Cell else {
            return
        }

        mediaService.fetchThumbnail(for: mediaItem, size: .zero, contentMode: .aspectFill) { image in
            cell.imageView.image = image
        }

        switch mediaItem.type {
        case .livePhoto:
            cell.livePhotoIconView.isHidden = false
            cell.timeDescriptionLabel.isHidden = true
        case .photo:
            cell.livePhotoIconView.isHidden = true
            cell.timeDescriptionLabel.isHidden = true
        case let .sloMoVideo(duration):
            cell.timeDescriptionLabel.text = fetchTimeDescription(duration)
            cell.timeDescriptionLabel.isHidden = false
            cell.livePhotoIconView.isHidden = true
        case let .video(duration):
            cell.timeDescriptionLabel.text = fetchTimeDescription(duration)
            cell.timeDescriptionLabel.isHidden = false
            cell.livePhotoIconView.isHidden = true
        case .unknown:
            cell.livePhotoIconView.isHidden = true
            cell.timeDescriptionLabel.isHidden = true
        }
    }

    func size(in collectionView: UICollectionView,
              sectionItem: CollectionViewSectionItem) -> CGSize {
        let inset = (internalInset * CGFloat((numberOfRows - 1)))
        let height = collectionView.bounds.width / 3 - inset
        let width = collectionView.bounds.width / 3 - inset
        return .init(width: width, height: height)
    }

    private func fetchTimeDescription(_ timeInterval: TimeInterval) -> String {
        let second = Int(timeInterval)
        let timeDescription = NSString(format: "%02d:%02d", second / 60, second % 60) as String
        return timeDescription
    }
}
