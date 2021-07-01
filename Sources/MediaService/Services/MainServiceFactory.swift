//
//  Copyright © 2018 Rosberry. All rights reserved.
//

import Foundation
import Photos

typealias ServicesAlias = HasFetchCollectionsService &
                          HasPermissionsService &
                          HasFetchAssetsService &
                          HasThumbnailCacheService &
                          HasCachingImageManager &
                          HasAssetResourceManager

// swiftlint:disable:this variable_name
public var Services: MainServicesFactory = .init()

public final class MainServicesFactory: ServicesAlias {
    lazy public var fetchCollectionsService: FetchCollectionsService = FetchCollectionsServiceImp()
    lazy public var permissionsService: PermissionsService = PermissionsServiceImp()
    lazy public var fetchAssetsService: FetchAssetsService = FetchAssetsServiceImp()
    lazy public var thumbnailCacheService: ThumbnailCacheService = ThumbnailCacheServiceImp()
    lazy public var cachingImageManager: CachingImageManager = CachingImageManagerImp()
    lazy public var assetResourceManager: AssetResourceManager = AssetResourceManagerImp()
}
