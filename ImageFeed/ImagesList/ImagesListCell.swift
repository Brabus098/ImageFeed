//  ImagesListCell.swift

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    // MARK: Property
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet private var cellImageView: UIImageView!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    weak var delegate: ImagesListCellDelegate?
    private var animationLayers = Set<CALayer>()
    
    
    // Метод настройки кастомной строки
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath, url: String, tableView: UITableView, likeStartState: Bool, data: Date?) {
        
        cell.cellImageView.kf.indicatorType = .activity // включаем индикатор
        guard let newImage = URL(string: "\(url)") else { return }
        
        cell.cellImageView.kf.setImage(with: newImage, // задаем картинку
                                       placeholder: UIImage(named: "PlaceHolderForImages")){ result in
        }
        
        // Настраиваем лайк
        self.setIsLiked(for: self, with: likeStartState)
        
        // Задаем дату и настриваем шрифт текста
        if let actualData = data {
            let actualFormatter = DateFormatterForCell.DateFormatterUtils.dateFormatter
            cell.dateLabel.text = actualFormatter.string(from: actualData)
        } else {
            cell.dateLabel.text = "" // задаем дату при отсутствии значения
        }
        cell.dateLabel.font = UIFont(name: "SFPro-Regular", size: 13)
    }
    
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked(for cell: ImagesListCell, with buttonStatus: Bool){
        cell.likeButton.setTitle("", for: .normal)
        buttonStatus ? cell.likeButton.setImage(.activeLike, for: .normal) : cell.likeButton.setImage(.unactiveLike, for: .normal)
    }
    
    private func showShimmer(over view: UIView) {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.locations = [0, 0.1, 0.3]
        
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = view.frame.height / 2
        gradient.masksToBounds = true
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
        
        animationLayers.insert(gradient)
        view.layer.addSublayer(gradient)
    }
    
    private func hideAllShimmers(animationSet:  Set<CALayer>) {
        animationLayers.forEach { gradient in
            gradient.removeFromSuperlayer()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Отменяем загрузку, чтобы избежать багов при переиспользовании ячеек
        cellImageView.image = nil
        cellImageView.kf.cancelDownloadTask()
        dateLabel.text = nil
    }
}
