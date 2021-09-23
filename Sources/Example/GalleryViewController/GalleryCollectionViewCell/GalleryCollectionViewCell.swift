//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import Framezilla

final class GalleryCollectionViewCell: UICollectionViewCell {

    private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private(set) lazy var timeDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .right
        label.font = label.font.withSize(13)
        return label
    }()

    private(set) lazy var livePhotoIconView: UIImageView = {
        let imageView = UIImageView()
        if #available(iOS 13.0, *) {
            imageView.image = UIImage(systemName: "livephoto")
        } else {
            // Fallback on earlier versions
        }
        imageView.tintColor = .white
        imageView.isHidden = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds

        livePhotoIconView.configureFrame { maker in
            maker.left(inset: 5).top(inset: 5).sizeToFit()
        }

        timeDescriptionLabel.configureFrame { maker in
            maker.right(inset: 8).bottom(inset: 8).sizeToFit()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        timeDescriptionLabel.text = nil
    }

    // MARK: - Private

    private func setup() {
        contentView.addSubview(imageView)
        contentView.addSubview(timeDescriptionLabel)
        contentView.addSubview(livePhotoIconView)
    }
}
