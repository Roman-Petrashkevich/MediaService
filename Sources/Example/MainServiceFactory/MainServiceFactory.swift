//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import Foundation
import MediaService

typealias ServicesAlias = HasMediaLibraryService

// swiftlint:disable:this variable_name
var Services: MainServicesFactory = .init()

final class MainServicesFactory: ServicesAlias {
    var mediaLibraryService: MediaLibraryService = MediaLibraryServiceImp()
}
