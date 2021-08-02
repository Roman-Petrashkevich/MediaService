//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import Photos

public class PermissionsServiceImp: PermissionsService {
    public func requestMediaLibraryPermissions(handler: @escaping (PHAuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) in
            handler(status)
        }
    }
    public init() {}
}
