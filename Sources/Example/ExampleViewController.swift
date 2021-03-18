//
//  Copyright © 2020 Rosberry. All rights reserved.
//
import UIKit
import MediaService

final class ExampleViewController: UIViewController {

    let dependencies = MediaLibraryServiceImp()

    private lazy var greetingLabel: UILabel = {
        let label = UILabel()
        label.text = "Greetings, traveller"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(greetingLabel)
        view.backgroundColor = .white
        dependencies.requestMediaLibraryPermissions()
        dependencies.fetchMediaItemCollections()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        greetingLabel.sizeToFit()
        greetingLabel.center = view.center
    }
}
