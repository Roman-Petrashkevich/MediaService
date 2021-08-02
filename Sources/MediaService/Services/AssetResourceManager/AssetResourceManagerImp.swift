//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import Photos
import UIKit

public class AssetResourceManagerImp: AssetResourceManager {
    public func writeData(for resource: PHAssetResource,
                          toFile url: URL,
                          options: PHAssetResourceRequestOptions?,
                          completion: @escaping (AVURLAsset) -> Void) {
        PHAssetResourceManager.default().writeData(for: resource,
                                                   toFile: url,
                                                   options: options) { _ in
            let asset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
            completion(asset)
        }
    }

    public init() {}
}
