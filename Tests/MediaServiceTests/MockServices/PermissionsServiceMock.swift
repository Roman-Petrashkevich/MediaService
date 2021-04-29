//
//  PermissionsServiceMock.swift
//  Example
//
//  Created by Evgeny Schwarzkopf on 28.04.2021.
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
