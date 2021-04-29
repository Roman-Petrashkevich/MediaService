//
//  PermissionsService.swift
//  Example
//
//  Created by Evgeny Schwarzkopf on 28.04.2021.
//

import Photos

public protocol PermissionsService {
    func requestMediaLibraryPermissions(handler: @escaping (PHAuthorizationStatus) -> Void)
}

public class PermissionsServiceImp: PermissionsService {
    public func requestMediaLibraryPermissions(handler: @escaping (PHAuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) in
            handler(status)
        }
    }
    public init() {}
}
