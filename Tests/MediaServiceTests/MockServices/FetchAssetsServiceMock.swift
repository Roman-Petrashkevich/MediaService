//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import MediaService
import Photos

final class FetchAssetsServiceMock: FetchAssetsService {

    var fetchAsset: PHAsset? = .init()
    var makeAsset: PHAsset? = .init()

    func fetchAssets(assetCollection: PHAssetCollection) -> PHAsset? {
        fetchAsset
    }

    func makeAsset(item: MediaItem) -> PHAsset? {
        makeAsset
    }
}
