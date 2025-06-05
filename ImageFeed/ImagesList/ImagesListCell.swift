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
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter}()
    private var todayDate = Date()
    
    // Метод настройки кастомной строки
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath, url: String, tableView: UITableView, likeStartState: Bool) {
        
        // Загружаем картинку
        cell.cellImageView.kf.indicatorType = .activity // включаем индикатор
        guard let newImage = URL(string: "\(url)") else { return }
        
        cell.cellImageView.kf.setImage(with: newImage, // задаем картинку
                                       placeholder: UIImage(named: "PlaceHolderForImages")){ result in
            //tableView.reloadRows(at: [indexPath], with: .none)
            //            switch result {
            //                   case .success(_):
            //                       // После успешной загрузки — перезагружаем строку
            //                       DispatchQueue.main.async {
            //                           tableView.reloadRows(at: [indexPath], with: .none)
            //                       }
            //                   case .failure(let error):
            //                       print("Ошибка загрузки изображения: \(error)")
            //                   }
        }
        
        // Настраиваем лайк
        self.setIsLiked(for: self, with: likeStartState)
        
        // Задаем дату и настриваем шрифт текста
        cell.dateLabel.text = dateFormatter.string(from: todayDate) // задаем дату
        cell.dateLabel.font = UIFont(name: "SFPro-Regular", size: 13)
        
    }
    
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked(for cell: ImagesListCell, with buttonStatus: Bool){
        cell.likeButton.setTitle("", for: .normal)
        buttonStatus ? cell.likeButton.setImage(.activeLike, for: .normal) : cell.likeButton.setImage(.unactiveLike, for: .normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Отменяем загрузку, чтобы избежать багов при переиспользовании ячеек
        cellImageView.image = nil
        cellImageView.kf.cancelDownloadTask()
        dateLabel.text = nil
    }
    
}
