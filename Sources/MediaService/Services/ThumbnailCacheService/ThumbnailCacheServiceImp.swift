//
//  FetchThumbnailService.swift
//  Example
//
//  Created by Evgeny Schwarzkopf on 29.04.2021.
//

import Photos
import UIKit

public class ThumbnailCacheServiceImp: ThumbnailCacheService {
    lazy public var thumbnailCache: NSCache<NSString, UIImage> = .init()
    public init() {}
}
