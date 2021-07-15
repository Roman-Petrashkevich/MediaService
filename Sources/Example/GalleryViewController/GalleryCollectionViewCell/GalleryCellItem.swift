//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import CollectionViewTools
import Photos
import MediaService

final class GalleryCellItem: CollectionViewDiffCellItem {
    typealias Cell = GalleryCollectionViewCell
    typealias Dependencies = HasMediaLibraryService

    private(set) var reuseType: ReuseType = .class(Cell.self)
    var diffIdentifier: String = ""

    private let dependencies: Dependencies
    private let mediaItem: MediaItem
    private let internalInset: CGFloat = 1.5
    private let numberOfRows: Int = 3

    init(dependencies: Dependencies, asset: PHAsset) {
        self.mediaItem = .init(asset: asset)
        self.dependencies = dependencies
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

        dependencies.mediaLibraryService.fetchThumbnail(for: mediaItem, size: .zero, contentMode: .aspectFit) { image in
            cell.imageView.image = image
        }

        switch mediaItem.type {
        case .livePhoto:
            cell.livePhotoIconView.isHidden = false
            cell.timeDescriptionLabel.isHidden = true
        case .photo:
            cell.livePhotoIconView.isHidden = true
            cell.timeDescriptionLabel.isHidden = true
        case let .sloMoVideo(duration), let .video(duration):
            cell.timeDescriptionLabel.text = formatTimeDescription(fromTimeInterval: duration)
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

    private func formatTimeDescription(fromTimeInterval timeInterval: TimeInterval) -> String {
        let second = Int(timeInterval)
        let timeDescription = NSString(format: "%02d:%02d", second / 60, second % 60) as String
        return timeDescription
    }
}
