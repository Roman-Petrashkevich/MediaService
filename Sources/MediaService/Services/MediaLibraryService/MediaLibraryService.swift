//
//  Copyright © 2018 Rosberry. All rights reserved.
//

import Ion
import Photos
import UIKit

public protocol HasMediaLibraryService {
    var mediaLibraryService: MediaLibraryService { get }
}

public protocol MediaLibraryService: AnyObject {

    typealias Completion<T> = (T) -> Void

    // MARK: - Sources

    var permissionStatusEventSource: AnyEventSource<PHAuthorizationStatus> { get }
    var mediaItemsEventSource: AnyEventSource<MediaItemsFetchResult> { get }
    var collectionsEventSource: AnyEventSource<[MediaItemsCollection]> { get }
    var mediaLibraryUpdateEventSource: AnyEventSource<PHChange> { get }
    var mediaItemFetchProgressEventSource: AnyEventSource<Float> { get }

    // MARK: - Permissions

    func requestMediaLibraryPermissions()

    // MARK: - Lists

    func fetchMediaItemCollections()
    func fetchMediaItems(in collection: MediaItemsCollection?, filter: MediaItemsFilter)

    // MARK: - Thumbnails

    func fetchThumbnail(for item: MediaItem, size: CGSize, contentMode: PHImageContentMode, completion: @escaping Completion<UIImage?>)
    func fetchThumbnail(for collection: MediaItemsCollection,
                        size: CGSize,
                        contentMode: PHImageContentMode,
                        completion: @escaping Completion<UIImage?>)

    // MARK: - Data

    func fetchImage(for item: MediaItem, completion: @escaping Completion<UIImage?>)
    func fetchImage(for item: MediaItem, options: PHImageRequestOptions, completion: @escaping Completion<UIImage?>)
    func fetchVideoAsset(for item: MediaItem, completion: @escaping Completion<AVAsset?>)
}
