//
//  MainCollectionViewCell.swift
//  Example
//
//  Created by Evgeny Schwarzkopf on 11.04.2021.
//

import Framezilla

final class MainCollectionViewCell: UICollectionViewCell {

    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = label.font.withSize(20)
        return label
    }()

    private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
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
        titleLabel.configureFrame { maker in
            maker.left(inset: 20).top(inset: 15).left().sizeToFit()
        }

        imageView.configureFrame { maker in
            maker.left().right().top(to: titleLabel.nui_bottom, inset: 10).bottom()
        }
    }

    private func setup() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(imageView)
    }
}
