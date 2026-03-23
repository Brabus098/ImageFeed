import Foundation
import UIKit

// MARK: - Protocols
protocol ImagesListViewProtocol: AnyObject {
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
        if ProcessInfo.processInfo.arguments.contains("isUITest") {
            return
        }
        
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
