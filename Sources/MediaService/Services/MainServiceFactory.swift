//
//  Copyright © 2018 Rosberry. All rights reserved.
//

import Foundation
import Photos

typealias ServicesAlias = HasMediaLibraryService

// swiftlint:disable:this variable_name
var Services: MainServicesFactory = .init()

final class MainServicesFactory: ServicesAlias {
    lazy var mediaLibraryService: MediaLibraryService = MediaLibraryServiceImp()
}
