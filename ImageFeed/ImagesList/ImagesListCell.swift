//  ImagesListCell.swift

import UIKit

final class ImagesListCell: UITableViewCell {
    
    // MARK: Property
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet var cellImageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    
    
}
