//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import Ion
import Photos
import MediaService

final class PermissionsServiceMock: PermissionsService {
    var status: PHAuthorizationStatus = .authorized

    func requestMediaLibraryPermissions(handler: @escaping (PHAuthorizationStatus) -> Void) {
        handler(status)
    }
}
