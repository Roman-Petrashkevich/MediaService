//
//  MainServiceFactory.swift
//  Example
//
//  Created by Evgeny Schwarzkopf on 01.07.2021.
//

import Foundation
import MediaService

typealias ServicesAlias = HasMediaLibraryService

// swiftlint:disable:this variable_name
var Services: MainServicesFactory = .init()

final class MainServicesFactory: ServicesAlias {
    var mediaLibraryService: MediaLibraryService = MediaLibraryServiceImp()
}
