import UIKit

final class FavoriteCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    @IBOutlet weak var ratingStackView: UIStackView!

    func configure(with item: FavoriteItem) {
        itemImageView.image =
            UIImage(named: item.imageName) ?? UIImage(systemName: "photo")
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle

        let rating = min(max(item.rating, 0), 5)
        let symbols = ratingStackView.arrangedSubviews.compactMap {
            $0 as? UIImageView
        }
        
        for (index, symbolView) in symbols.enumerated() {
            symbolView.image = UIImage(
                systemName: index < rating ? "star.fill" : "star"
            )
        }

        ratingStackView.isAccessibilityElement = true
        ratingStackView.accessibilityLabel = "Rating \(rating) out of 5"
    }
}
