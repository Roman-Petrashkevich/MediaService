//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import Photos

public final class MediaItemsFetchResult {
    public let collection: MediaItemsCollection
    public let filter: MediaItemsFilter
    public let fetchResult: PHFetchResult<PHAsset>

    public init(collection: MediaItemsCollection, filter: MediaItemsFilter, fetchResult: PHFetchResult<PHAsset>) {
        self.collection = collection
        self.filter = filter
        self.fetchResult = fetchResult
    }
}
