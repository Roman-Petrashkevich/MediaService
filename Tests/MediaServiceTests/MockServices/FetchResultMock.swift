//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import UIKit
import Photos
import MediaService

protocol FetchResult {
    func mediaType(_ index: Int) -> PHAssetMediaType
}

extension PHFetchResult: FetchResult {
    @objc func mediaType(_ index: Int) -> PHAssetMediaType {
        switch index {
        case 0:
            return .video
        case 1:
            return .image
        case 2:
            return .image
        default:
            return .unknown
        }
    }
}
