//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import Photos

public protocol HasFetchAssetsService {
    var fetchAssetsService: FetchAssetsService { get }
}

public protocol FetchAssetsService {
    func fetchAssets(assetCollection: PHAssetCollection) -> PHAsset?
    func makeAsset(item: MediaItem) -> PHAsset?
}
