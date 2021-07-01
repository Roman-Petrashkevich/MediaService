//
//  PermissionsService.swift
//  MediaService
//
//  Created by Evgeny Schwarzkopf on 01.07.2021.
//

import Photos

public protocol HasPermissionsService {
    var permissionsService: PermissionsService { get }
}

public protocol PermissionsService {
    func requestMediaLibraryPermissions(handler: @escaping (PHAuthorizationStatus) -> Void)
}
