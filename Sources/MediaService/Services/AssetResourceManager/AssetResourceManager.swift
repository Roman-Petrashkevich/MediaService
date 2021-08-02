//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import Photos

public protocol HasAssetResourceManager {
    var assetResourceManager: AssetResourceManager { get }
}

public protocol AssetResourceManager: AnyObject {
    func writeData(for resource: PHAssetResource,
                   toFile url: URL,
                   options: PHAssetResourceRequestOptions?,
                   completion: @escaping (AVURLAsset) -> Void)
}
