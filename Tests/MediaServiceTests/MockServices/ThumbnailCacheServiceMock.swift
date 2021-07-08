//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import MediaService
import Photos
import UIKit

final class ThumbnailCacheServiceMock: ThumbnailCacheService {
    var thumbnailCache: NSCache<NSString, UIImage> = .init()
}
