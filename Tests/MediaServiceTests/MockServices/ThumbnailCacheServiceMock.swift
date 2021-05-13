//
//  FetchThumbnailService.swift
//  Example
//
//  Created by Evgeny Schwarzkopf on 29.04.2021.
//

import MediaService
import Photos
import UIKit

final class ThumbnailCacheServiceMock: ThumbnailCacheService {
    var thumbnailCache: NSCache<NSString, UIImage> = .init()
}
