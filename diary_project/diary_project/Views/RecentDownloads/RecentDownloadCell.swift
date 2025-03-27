import UIKit

class RecentDownloadCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let checkmark = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(checkmark)
        imageView.frame = contentView.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        checkmark.image = UIImage(systemName: "checkmark.circle.fill")
        checkmark.tintColor = .systemGreen
        checkmark.frame = CGRect(x: contentView.frame.width - 24, y: 76, width: 16, height: 16)
        checkmark.isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with photoPath: String, isSelected: Bool) {
        if let image = UIImage(contentsOfFile: photoPath) {
            imageView.image = image
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
        checkmark.isHidden = !isSelected
    }
}
