//
//  Copyright © 2018 Rosberry. All rights reserved.
//

import Foundation

public enum MediaItemFilter: Int, CaseIterable {
    case video
    case all

    public func matches(item: MediaItem) -> Bool {
        switch self {
        case .video:
            return item.type.isVideo
        case .all:
            return true
        }
    }
}
