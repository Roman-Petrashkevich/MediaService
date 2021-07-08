//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import Photos

public protocol HasPermissionsService {
    var permissionsService: PermissionsService { get }
}

public protocol PermissionsService {
    func requestMediaLibraryPermissions(handler: @escaping (PHAuthorizationStatus) -> Void)
}
