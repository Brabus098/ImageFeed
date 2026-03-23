//  ImagesListCell.swift

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    // MARK: Property
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    private var animationLayers = Set<CALayer>()
    
    // MARK: - UI Elements
    private let cellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFPro-Regular", size: 13)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        layoutConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Setup
    private func setupViews() {
        contentView.addSubview(cellImageView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(likeButton)
        contentView.backgroundColor = .ypBlackIOS
        
        likeButton.addTarget(self, action: #selector(likeButtonClicked), for: .touchUpInside)
    }
    
    private func layoutConstraints() {
        NSLayoutConstraint.activate([
            
            cellImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            dateLabel.leadingAnchor.constraint(equalTo: cellImageView.leadingAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: cellImageView.bottomAnchor, constant: -8),
            
            likeButton.trailingAnchor.constraint(equalTo: cellImageView.trailingAnchor),
            likeButton.topAnchor.constraint(equalTo: cellImageView.topAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // Метод настройки кастомной строки
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath, url: String, tableView: UITableView, likeStartState: Bool, data: Date?) {
        
        cell.cellImageView.kf.indicatorType = .activity
        guard let newImage = URL(string: "\(url)") else { return }
        
        cell.cellImageView.kf.setImage(with: newImage,
                                       placeholder: UIImage(named: "PlaceHolderForImages")){ result in
        }
        
        self.setIsLiked(for: self, with: likeStartState)
        
        if let actualData = data {
            let actualFormatter = DateFormatterUtils.dateFormatter
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
        if buttonStatus {
            cell.likeButton.setImage(.activeLike, for: .normal)
            cell.likeButton.accessibilityIdentifier = "activeLike"
        } else {
            cell.likeButton.setImage(.unactiveLike, for: .normal)
            cell.likeButton.accessibilityIdentifier = "unactiveLike"
        }
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
        cellImageView.image = nil
        cellImageView.kf.cancelDownloadTask()
        dateLabel.text = nil
    }
}
