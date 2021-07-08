//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import MediaService
import Photos

final class FetchAssetsServiceMock: FetchAssetsService {

    var fetchAssetMock: PHAsset? = .init()
    var makeAssetMock: PHAsset? = .init()

    func fetchAssets(assetCollection: PHAssetCollection) -> PHAsset? {
        fetchAssetMock
    }

    func makeAsset(item: MediaItem) -> PHAsset? {
        makeAssetMock
    }
}
