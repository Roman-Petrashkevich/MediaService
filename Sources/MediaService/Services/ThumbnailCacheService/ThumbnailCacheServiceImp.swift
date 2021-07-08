//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import Photos
import UIKit

public class ThumbnailCacheServiceImp: ThumbnailCacheService {
    lazy public var thumbnailCache: NSCache<NSString, UIImage> = .init()
    public init() {}
}
