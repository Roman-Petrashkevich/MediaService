//
//  FetchThumbnailService.swift
//  Example
//
//  Created by Evgeny Schwarzkopf on 29.04.2021.
//

import Photos
import UIKit

public protocol ThumbnailCacheService {
    var thumbnailCache: NSCache<NSString, UIImage> { get }
}

public class ThumbnailCacheServiceImp: ThumbnailCacheService {
    lazy public var thumbnailCache: NSCache<NSString, UIImage> = .init()
    public init() {}
}
