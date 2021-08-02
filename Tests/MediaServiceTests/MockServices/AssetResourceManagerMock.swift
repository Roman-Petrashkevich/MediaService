//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import UIKit
import Photos
import MediaService

final class AssetResourceManagerMock: AssetResourceManager {
    func writeData(for resource: PHAssetResource,
                   toFile url: URL,
                   options: PHAssetResourceRequestOptions?,
                   completion: @escaping (AVURLAsset) -> Void) {
        var videoURL: URL {
            URL(fileURLWithPath: Bundle(for: Self.self).path(forResource: "VideoTest", ofType: "mov") ?? "")
        }
        let asset = AVURLAsset(url: videoURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        completion(asset)
    }
}
