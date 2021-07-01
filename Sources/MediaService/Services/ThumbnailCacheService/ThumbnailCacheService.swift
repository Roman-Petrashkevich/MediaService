//
//  ThumbnailCacheService.swift
//  MediaService
//
//  Created by Evgeny Schwarzkopf on 01.07.2021.
//

import Photos
import UIKit

public protocol HasThumbnailCacheService {
    var thumbnailCacheService: ThumbnailCacheService { get }
}

public protocol ThumbnailCacheService {
    var thumbnailCache: NSCache<NSString, UIImage> { get }
}
