//
//  Copyright © 2018 Rosberry. All rights reserved.
//

import Foundation

public enum MediaItemsFilter: Int, CaseIterable {
    case video
    case sloMoVideo
    case livePhoto
    case photo
    case all
    case unknown

    public func matches(item: MediaItem) -> Bool {
        switch self {
        case .unknown:
            return item.type.isUnknown
        case .video:
            return item.type.isVideo
        case .photo:
            return item.type.isPhoto
        case .livePhoto:
            return item.type.isLivePhoto
        case .sloMoVideo:
            return item.type.isSloMoVideo
        case .all:
            return true
        }
    }
}
