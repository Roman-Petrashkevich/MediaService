//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import Photos
import UIKit

public protocol HasThumbnailCacheService {
    var thumbnailCacheService: ThumbnailCacheService { get }
}

public protocol ThumbnailCacheService {
    var thumbnailCache: NSCache<NSString, UIImage> { get }
}
