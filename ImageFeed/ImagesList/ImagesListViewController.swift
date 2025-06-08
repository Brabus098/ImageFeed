//  ImagesListViewController.swift

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var tabBar: UITabBarItem!
    @IBOutlet private var tableView: UITableView!
    private let imagesListService = ImagesListService()
    var photos = [Photo]()
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagesListService.fetchPhotosNextPage()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateTableViewAnimated),
                                               name: ImagesListService.didChangeNotification,
                                               object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == Constants.showSingleImage{
            guard
                let viewController = segue.destination as? SingleImageViewController, // Проверяем что наш сигвей идет к нужному контроллеру
                let indexPath = sender as? IndexPath // проверяем что нам пришел именно адрес конкретной строки
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let stringBigImage = photos[indexPath.row].largeImageURL
            guard let urlBigImage = URL(string: stringBigImage) else { return }
            viewController.imageURL = urlBigImage// передаем картинку внутрь singleView в свойство image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // Метод добавляет новые строки при обновлении массива
    @objc private func updateTableViewAnimated(){
        
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        var indexPaths: [IndexPath] = []
        
        if oldCount != newCount {
            tableView.performBatchUpdates {
                for i in oldCount..<newCount {
                    indexPaths.append(IndexPath(row: i, section: 0))
                    photos.append(imagesListService.photos[i])
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
}

// MARK: UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.showSingleImage, sender: indexPath)
    }
}

// MARK: UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        imageListCell.configCell(for: imageListCell,
                                 with: indexPath,
                                 url: photos[indexPath.row].thumbImageURL,
                                 tableView: tableView,
                                 likeStartState: photos[indexPath.row].isLiked,
                                 data: photos[indexPath.row].createdAt
        )
        return imageListCell
    }
    
    // Метод вызывается прямо перед тем, как ячейка таблицы будет показана на экране
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ){
        if indexPath.row + 1 == photos.count{
            imagesListService.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    // Поиск индекса элемента
                    if let index = self.photos.firstIndex(where: { $0.id == photo.id }){
                        // Текущий элемент
                        let photo = self.photos[index]
                        let newPhoto = Photo(id: photo.id,
                                             size: photo.size,
                                             createdAt: photo.createdAt,
                                             welcomeDescription: photo.welcomeDescription,
                                             thumbImageURL: photo.thumbImageURL,
                                             largeImageURL: photo.largeImageURL,
                                             isLiked: !photo.isLiked)
                        
                        var newPhotos = self.photos
                        newPhotos[index] = newPhoto
                        self.photos = newPhotos
                        
                        cell.setIsLiked(for: cell, with: !photo.isLiked)
                        UIBlockingProgressHUD.dismiss()
                    }
                }
            case . failure(_):
                print("[imageListCellDidTapLike]: ошибка в запросе")
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
}
