import Foundation
import UIKit

// MARK: - Protocols
protocol ImagesListViewProtocol: AnyObject {
    func updatesTableViewAnimated(oldCount: Int, newCount: Int)
    func reloadCell(at indexPath: IndexPath, isLiked: Bool)
    func presentSingleImageViewer(with url: URL)
}

protocol ImagesListPresenterProtocol: AnyObject {
    var photos: [Photo] { get }
    func viewDidLoad()
    func addCell() -> [IndexPath]
    func didSelectImage(at indexPath: IndexPath)
    func toggleLike(at indexPath: IndexPath)
}



// MARK: - ViewController

final class ImagesListViewController: UIViewController, ImagesListViewProtocol {

    var presenter: ImagesListPresenterProtocol?
    private let tableView = UITableView()
    private let notificationName = Notification.Name("ImagesListServiceDidChange")
    

    init(presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupNotifications()
        presenter?.viewDidLoad()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.accessibilityIdentifier = "FeedTableView"
        tableView.backgroundColor = .ypBlackIOS
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableViewAnimated), name: notificationName, object: nil)
    }

    @objc private func updateTableViewAnimated() {
        guard let indexPaths = presenter?.addCell() else { return }
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }

    func updatesTableViewAnimated(oldCount: Int, newCount: Int) {    }

    func reloadCell(at indexPath: IndexPath, isLiked: Bool) {
        if let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell {
            cell.setIsLiked(for: cell, with: isLiked)
        }
    }

    func presentSingleImageViewer(with url: URL) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SingleImageViewController") as? SingleImageViewController else {
            return
        }
        vc.imageURL = url
        present(vc, animated: true)
    }
}

// MARK: - TableView DataSource & Delegate

extension ImagesListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.photos.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell,
              let photo = presenter?.photos[indexPath.row] else {
            return UITableViewCell()
        }

        cell.delegate = self
        cell.configCell(for: cell,
                        with: indexPath,
                        url: photo.thumbImageURL,
                        tableView: tableView,
                        likeStartState: photo.isLiked,
                        data: photo.createdAt)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didSelectImage(at: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let count = presenter?.photos.count, indexPath.row + 1 == count {
            presenter?.viewDidLoad()
        }
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.toggleLike(at: indexPath)
    }
}

////  ImagesListViewController.swift
//
//import UIKit
//import Kingfisher
//protocol ImagesListPresenterProtocol {
//    var view: ImagesListViewProtocol? { get set }// для установки зависимости с controller
//    var photos: [Photo] { get set } // для второй ответственности
//    
//    func setupImage(at indexPath: IndexPath) -> URL // для третьей ответсвенности которая была в segue а сейчас в didSelectRowAt
//    func addCell() -> [IndexPath] //  Четвертая ответственность логика добавления новых данных
//    func changeLikeStatus(photoId: String, likeStatus: Bool) //  Пятая ответственность логика добавления новых данных
//}
//
//final class ImagesListPresenter: ImagesListPresenterProtocol{
//    var view: ImagesListViewProtocol?
//    var imageListService: ImageListServiceProtocol?
//    
//    var photos: [Photo] = [] // для второй ответственности
//    
//    func setupImage(at indexPath: IndexPath) -> URL { // Третья ответственность
//        
//        let stringBigImage = photos[indexPath.row].largeImageURL
//        guard let urlBigImage = URL(string: stringBigImage) else { return URL(fileURLWithPath: "")}
//        return urlBigImage
//    }
//    
//    func addCell() -> [IndexPath]{ // Четвертая ответственность логика добавления новых данных
//        
//        let oldCount = photos.count
//        let newCount = imageListService?.photos.count // imagesListService.photos.count  было до обновления imagesListService
//        var indexPaths: [IndexPath] = []
//        
//        if oldCount != newCount {
//            if let newCount, let imageListService {
//                for i in oldCount..<newCount {
//                    indexPaths.append(IndexPath(row: i, section: 0))
//                    photos.append(imageListService.photo(at: i))
//                }
//            }
//        }
//        return indexPaths
//    }
//    
//    func changeLikeStatus(photoId: String, likeStatus: Bool) {
//        // Поиск индекса элемента
//        if let index = self.photos.firstIndex(where: { $0.id == photoId }){ // Пятая ответственность логика обновления массива данных
//            // Текущий элемент
//            let photo = self.photos[index]
//            let newPhoto = Photo(id: photo.id,
//                                 size: photo.size,
//                                 createdAt: photo.createdAt,
//                                 welcomeDescription: photo.welcomeDescription,
//                                 thumbImageURL: photo.thumbImageURL,
//                                 largeImageURL: photo.largeImageURL,
//                                 isLiked: !photo.isLiked)
//            
//            var newPhotos = self.photos
//            newPhotos[index] = newPhoto
//            self.photos = newPhotos
//            
//        }
//    }
//    
//    init(view: ImagesListViewProtocol? = nil, imageListService: ImageListServiceProtocol? = nil, photos: [Photo]) {
//        self.view = view
//        self.imageListService = imageListService
//        self.photos = photos
//    }
//}
//
//protocol ImagesListViewProtocol: AnyObject {
//    func updatesTableViewAnimated(oldCount: Int, newCount: Int)
//    func reloadCell(at indexPath: IndexPath, isLiked: Bool)
//    func presentSingleImageViewer(with url: URL)
//}
//
//
//final class ImagesListViewController: UIViewController & ImagesListViewProtocol { // прямая задача - обновление UI
//
//    // MARK: Properties
//    var presenter: ImagesListPresenterProtocol?
//    private let tableView = UITableView()
//    var storyboardReference: UIStoryboard?
//    
//    var imagesListService: ImageListServiceProtocol? // Первая ответственность обращение к другому сервису (инверсия зависимостей)
//    //var photos = [Photo]() // Вторая ответственность хранение данных
//    
//    static let didChangesNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
//    
//    init(imagesListService: ImageListServiceProtocol, storyboard: UIStoryboard?, presenter: ImagesListPresenterProtocol ) {
//        self.imagesListService = imagesListService
//        self.storyboardReference = storyboard
//        self.presenter = presenter
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: LifeCycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        imagesListService?.fetchPhotosNextPage() // imagesListService.fetchPhotosNextPage() было до инверсии
//        
//        setupUI()
//        setupTableView()
//        setupNotifications()
//        
//    }
//    // Layout tableView
//    private func setupUI() {
//        view.backgroundColor = .systemBackground
//        view.addSubview(tableView)
//        
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.topAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
//    }
//    // Настраиваем зависимости tableView
//    private func setupTableView() {
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.backgroundColor = .ypBlackIOS
//        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
//        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
//        
//    }
//    
//    private func setupNotifications() {
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(updateTableViewAnimated),
//                                               name: ImagesListViewController.didChangesNotification,
//                                               object: nil)
//    }
//    // Метод добавляет новые строки при обновлении массива
//    @objc private func updateTableViewAnimated(){ // Четвертая ответственность логика обновления данных
//            tableView.performBatchUpdates {
//                if let indexPaths = presenter?.addCell(){
//                    tableView.insertRows(at: indexPaths, with: .automatic)
//                }
//            }
//    }
//}
//
//// MARK: UITableViewDelegate
//extension ImagesListViewController: UITableViewDelegate {
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        guard let viewController = storyboardReference?.instantiateViewController(withIdentifier: "SingleImageViewController") as? SingleImageViewController else {   print("[ImagesListViewController] : не найдена связь для перехода")
//            return }
//        
//        // MARK: перешло из сеги
////        let stringBigImage = photos[indexPath.row].largeImageURL // Третья ответсвенность
////        guard let urlBigImage = URL(string: stringBigImage) else { return }
//        var urlBigImage = presenter?.setupImage(at: indexPath)
//        viewController.imageURL = urlBigImage // передаем картинку внутрь singleView в свойство image
//        
//        self.present(viewController, animated: true)
//    }
//}
//
//// MARK: UITableViewDataSource
//extension ImagesListViewController: UITableViewDataSource {
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if let presenter {
//            return presenter.photos.count
//        }
//        return 0
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(
//            withIdentifier: ImagesListCell.reuseIdentifier,
//            for: indexPath
//        ) as? ImagesListCell else {
//            return UITableViewCell()
//        }
//        guard let presenter else { return UITableViewCell() }
//        cell.delegate = self
//        var path = presenter.photos[indexPath.row]
//        cell.configCell(for: cell,
//                        with: indexPath,
//                        url: path.thumbImageURL,
//                        tableView: tableView,
//                        likeStartState: path.isLiked,
//                        data: path.createdAt
//        )
//        return cell
//    }
//    
//    // Метод вызывается прямо перед тем, как ячейка таблицы будет показана на экране
//    func tableView(
//        _ tableView: UITableView,
//        willDisplay cell: UITableViewCell,
//        forRowAt indexPath: IndexPath
//    ){
//        guard let presenter else { return }
//        if indexPath.row + 1 == presenter.photos.count{
//            imagesListService?.fetchPhotosNextPage() // imagesListService.fetchPhotosNextPage() было до обновления imagesListService
//        }
//    }
//}
//
//extension ImagesListViewController: ImagesListCellDelegate {
//    func imageListCellDidTapLike(_ cell: ImagesListCell) {
//        
//        guard let indexPath = tableView.indexPath(for: cell), let presenter else { return }
//        let photo = presenter.photos[indexPath.row]
//        
//        UIBlockingProgressHUD.show()
//        
//        imagesListService?.changeLike(photoId: photo.id, isLike: photo.isLiked) { result in // imagesListService?.changeLike было до обновления imagesListService
//            switch result {
//            case .success(_):
//                DispatchQueue.main.async {
//                    // Поиск индекса элемента
//                    if let index = presenter.photos.firstIndex(where: { $0.id == photo.id }){ // Пятая ответственность логика обновления массива данных
//                        // Текущий элемент
//                        let photo = presenter.photos[index]
//                        let newPhoto = Photo(id: photo.id,
//                                             size: photo.size,
//                                             createdAt: photo.createdAt,
//                                             welcomeDescription: photo.welcomeDescription,
//                                             thumbImageURL: photo.thumbImageURL,
//                                             largeImageURL: photo.largeImageURL,
//                                             isLiked: !photo.isLiked)
//                        
//                        var newPhotos = presenter.photos
//                        newPhotos[index] = newPhoto
//                        presenter.photos = newPhotos
//                        
//                        cell.setIsLiked(for: cell, with: !photo.isLiked)
//                        UIBlockingProgressHUD.dismiss()
//                    }
//                }
//            case . failure(_):
//                print("[imageListCellDidTapLike]: ошибка в запросе")
//                UIBlockingProgressHUD.dismiss()
//            }
//        }
//    }
//}
//
//extension ImagesListViewController{
//    func updatesTableViewAnimated(oldCount: Int, newCount: Int) {
//        
//    }
//    
//    func reloadCell(at indexPath: IndexPath, isLiked: Bool) {
//        
//    }
//    
//    func presentSingleImageViewer(with url: URL) {
//        
//    }
//}
