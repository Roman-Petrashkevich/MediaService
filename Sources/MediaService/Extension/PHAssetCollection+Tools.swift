//
//  Copyright © 2018 Rosberry. All rights reserved.
//

import Photos

extension PHAssetCollection {
    public var currentAssetItemsCount: Int {
        currentAssetCountWith(nil)
    }

    public func currentAssetCountWith(_ type: PHAssetMediaType?) -> Int {
        let fetchOptions = PHFetchOptions()
        if let type = type {
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", type.rawValue)
        }
        let result = PHAsset.fetchAssets(in: self, options: fetchOptions)
        return result.count
    }
}
