//
//  Copyright © 2018 Rosberry. All rights reserved.
//

import Ion
import Photos
import UIKit

public final class MediaLibraryServiceImp: NSObject, MediaLibraryService {

    private lazy var permissionStatusEmitter: Emitter<PHAuthorizationStatus> = .init()
    public lazy var permissionStatusEventSource: AnyEventSource<PHAuthorizationStatus> = .init(permissionStatusEmitter)

    private lazy var mediaItemsEmitter: Emitter<MediaItemsFetchResult> = .init()
    public lazy var mediaItemsEventSource: AnyEventSource<MediaItemsFetchResult> = .init(mediaItemsEmitter)

    private lazy var collectionsEmitter: Emitter<[MediaItemsCollection]> = .init()
    public lazy var collectionsEventSource: AnyEventSource<[MediaItemsCollection]> = .init(collectionsEmitter)

    private lazy var mediaLibraryUpdateEmitter: Emitter<PHChange> = .init()
    public lazy var mediaLibraryUpdateEventSource: AnyEventSource<PHChange> = .init(mediaLibraryUpdateEmitter)

    private lazy var mediaItemFetchProgressEmitter: Emitter<Float> = .init()
    public lazy var mediaItemFetchProgressEventSource: AnyEventSource<Float> = .init(mediaItemFetchProgressEmitter)

    private var didRegisterForMediaLibraryUpdates: Bool = false

    public typealias Dependencies = HasFetchCollectionsService &
                                    HasPermissionsService &
                                    HasFetchAssetsService &
                                    HasThumbnailCacheService &
                                    HasCachingImageManager &
                                    HasAssetResourceManager
     private let dependencies: Dependencies

     public init(dependencies: Dependencies = Services) {
         self.dependencies = dependencies
     }

    // MARK: - Permissions

    public func requestMediaLibraryPermissions() {
        dependencies.permissionsService.requestMediaLibraryPermissions { (status: PHAuthorizationStatus) in
            DispatchQueue.main.async {
                self.permissionStatusEmitter.replace(status)
            }
        }
    }

    // MARK: - Lists

    public func fetchMediaItemCollections() {
        DispatchQueue.global(qos: .background).async {
            var collections = [MediaItemsCollection]()

            if let userLibraryCollection = self.dependencies.fetchCollectionsService.fetchCollections(with: .smartAlbum,
                                                                                                      subtype: .smartAlbumUserLibrary,
                                                                                                      options: nil).first {
                collections.append(userLibraryCollection)
            }

            if let favoritesCollection = self.dependencies.fetchCollectionsService.fetchCollections(with: .smartAlbum,
                                                                                                    subtype: .smartAlbumFavorites,
                                                                                                    options: nil).first,
                favoritesCollection.estimatedMediaItemsCount != 0 {
                favoritesCollection.isFavorite = true
                collections.append(favoritesCollection)
            }

            let allCollections = self.dependencies.fetchCollectionsService.fetchCollections(with: .album,
                                                                                            subtype: .any,
                                                                                            options: nil).filter { collection in
                collection.estimatedMediaItemsCount != 0
            }
            collections.append(contentsOf: allCollections)

            DispatchQueue.main.async {
                self.registerForMediaLibraryUpdatesIfNeeded()
                self.collectionsEmitter.replace(collections)
            }
        }
    }

    public func fetchMediaItems(in collection: MediaItemsCollection?, filter: MediaItemFilter = .all) {
        guard let collection = collection else {
            let collection = dependencies.fetchCollectionsService.fetchCollections(with: .smartAlbum,
                                                                                   subtype: .smartAlbumUserLibrary,
                                                                                   options: nil).first
            fetchMediaItems(in: collection, filter: filter)
            return
        }
        DispatchQueue.global(qos: .background).async {
            guard let assetCollection = self.dependencies.fetchCollectionsService.fetchAssetCollections(localIdentifiers: [collection.identifier],
                                                                                                        options: nil) else {
                return
            }

            let mediaType: PHAssetMediaType? = filter == .all ? nil : .video
            guard let fetchResult = self.dependencies.fetchCollectionsService.fetchMediaItems(in: assetCollection,
                                                                                              mediaType: mediaType) else {
                return
            }

            DispatchQueue.main.async {
                self.registerForMediaLibraryUpdatesIfNeeded()
                let result = MediaItemsFetchResult(collection: collection, filter: filter, fetchResult: fetchResult)
                self.mediaItemsEmitter.replace(result)
            }
        }
    }

    // MARK: - Thumbnails

    public func fetchThumbnail(for item: MediaItem,
                               size: CGSize,
                               contentMode: PHImageContentMode,
                               completion: @escaping Completion<UIImage?>) {
        if let thumbnail = item.thumbnail, thumbnail.size == size {
            completion(thumbnail)
            return
        }

        DispatchQueue.global(qos: .background).async {
            guard let asset = self.dependencies.fetchAssetsService.makeAsset(item: item) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            self.fetchThumbnail(for: asset, size: size, contentMode: contentMode) { (image: UIImage?) in
                item.thumbnail = image
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }

    public func fetchThumbnail(for collection: MediaItemsCollection,
                               size: CGSize,
                               contentMode: PHImageContentMode,
                               completion: @escaping Completion<UIImage?>) {
        if let thumbnail = collection.thumbnail, thumbnail.size == size {
            completion(thumbnail)
            return
        }

        DispatchQueue.global(qos: .background).async {
            guard let assetCollection = self.dependencies.fetchCollectionsService.fetchAssetCollections(localIdentifiers: [collection.identifier],
                                                                                           options: nil) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            guard let asset = self.dependencies.fetchAssetsService.fetchAssets(assetCollection: assetCollection) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            self.fetchThumbnail(for: asset, size: size, contentMode: contentMode) { (image: UIImage?) in
                collection.thumbnail = image
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }

    // MARK: - Data

    public func fetchImage(for item: MediaItem, completion: @escaping Completion<UIImage?>) {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        options.progressHandler = { [weak self] (progress: Double, _, _, _) in
            DispatchQueue.main.async {
                self?.mediaItemFetchProgressEmitter.replace(Float(progress))
            }
        }
        fetchImage(for: item, options: options, completion: completion)
    }

    public func fetchImage(for item: MediaItem,
                           options: PHImageRequestOptions,
                           completion: @escaping Completion<UIImage?>) {
        guard let asset = dependencies.fetchAssetsService.makeAsset(item: item) else {
            completion(nil)
            return
        }

        dependencies.cachingImageManager.requestImageData(for: asset, options: options) { (imageData: Data?) in
            guard let data = imageData else {
                completion(nil)
                return
            }

            let image = UIImage(data: data)
            DispatchQueue.main.async {
                self.mediaItemFetchProgressEmitter.discard()
                completion(image)
            }
        }
    }

    // swiftlint:disable:next function_body_length
    public func fetchVideoAsset(for item: MediaItem, completion: @escaping Completion<AVAsset?>) {
        guard let asset = dependencies.fetchAssetsService.makeAsset(item: item) else {
            completion(nil)
            return
        }

        if item.type.isVideo {
            let requestOptions = PHVideoRequestOptions()
            requestOptions.isNetworkAccessAllowed = true
            requestOptions.progressHandler = { [weak self] (progress: Double, _, _, _) in
                DispatchQueue.main.async {
                    self?.mediaItemFetchProgressEmitter.replace(Float(progress))
                }
            }

            dependencies.cachingImageManager.requestAVAsset(forVideo: asset, options: requestOptions) { (asset: AVAsset?) in
                DispatchQueue.main.async {
                    self.mediaItemFetchProgressEmitter.discard()
                    completion(asset)
                }
            }
        }
        else if item.type.isLivePhoto {
            let requestOptions = PHLivePhotoRequestOptions()
            requestOptions.isNetworkAccessAllowed = true
            requestOptions.deliveryMode = .highQualityFormat
            requestOptions.progressHandler = { [weak self] (progress: Double, _, _, _) in
                DispatchQueue.main.async {
                    self?.mediaItemFetchProgressEmitter.replace(Float(progress))
                }
            }

            dependencies.cachingImageManager.requestLivePhoto(for: asset,
                                                              targetSize: .zero,
                                                              contentMode: .default,
                                                              options: requestOptions) { (photo: PHLivePhoto?) in
                guard let photo = photo else {
                    return completion(nil)
                }

                let resources = PHAssetResource.assetResources(for: photo)
                guard let videoResource = resources.first(where: { (resource: PHAssetResource) -> Bool in
                    return resource.type == .pairedVideo
                }) else {
                    return completion(nil)
                }

                let url = self.prepareOutputURL(forAssetIdentifier: videoResource.assetLocalIdentifier)
                let requestOptions = PHAssetResourceRequestOptions()
                requestOptions.isNetworkAccessAllowed = true
                self.dependencies.assetResourceManager.writeData(for: videoResource,
                                                                 toFile: url,
                                                                 options: requestOptions,
                                                                 completion: { asset in
                    DispatchQueue.main.async {
                        self.mediaItemFetchProgressEmitter.discard()
                        completion(asset)
                    }
                })
            }
        }
        else {
            completion(nil)
        }
    }

    // MARK: - Private

    private func registerForMediaLibraryUpdatesIfNeeded() {
        guard didRegisterForMediaLibraryUpdates == false else {
            return
        }
        PHPhotoLibrary.shared().register(self)
        didRegisterForMediaLibraryUpdates = true
    }

    private func prepareOutputURL(forAssetIdentifier identifier: String) -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(identifier.replacingOccurrences(of: "/", with: "_"))
            .appendingPathExtension("mov")
        try? FileManager.default.removeItem(at: url)
        return url
    }

    private func fetchThumbnail(for asset: PHAsset,
                                size: CGSize,
                                contentMode: PHImageContentMode,
                                completion: @escaping Completion<UIImage?>) {
        if let thumbnail = dependencies.thumbnailCacheService.thumbnailCache.object(forKey: asset.localIdentifier as NSString) {
            completion(thumbnail)
            return
        }

        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true

        dependencies.cachingImageManager.requestImage(for: asset,
                                                      targetSize: size,
                                                      contentMode: contentMode,
                                                      options: options) { [weak self] (image: UIImage?) in
            if let image = image {
                self?.dependencies.thumbnailCacheService.thumbnailCache.setObject(image, forKey: asset.localIdentifier as NSString)
            }

            completion(image)
        }
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension MediaLibraryServiceImp: PHPhotoLibraryChangeObserver {

    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.mediaLibraryUpdateEmitter.replace(changeInstance)
        }
    }
}
