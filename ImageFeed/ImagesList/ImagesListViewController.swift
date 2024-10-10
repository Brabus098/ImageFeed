//  ViewController.swift

import UIKit

final class ImagesListViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var tabBar: UITabBarItem!
    @IBOutlet private var tableView: UITableView!
    private let photosName: [String] = Array(0..<20).map { "\($0)"}
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter}()
    private var todayDate = Date()
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0) // Добавляем отступы сверху и снизу для контента таблицы
    }
    
    // Метод настройки кастомной строки
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.likeButton.setTitle("", for: .normal)
        indexPath.row % 2 == 0 ? cell.likeButton.setImage(.unactiveLike, for: .normal) : cell.likeButton.setImage(.activeLike, for: .normal)
        
        // Проверяем есть ли значение по адресу
        guard let newImage = UIImage(named: "\(indexPath.row)") else { return }
        cell.cellImageView.image = newImage // задаем картинку
        cell.dateLabel.text = dateFormatter.string(from: todayDate) // задаем дату
        cell.dateLabel.font = UIFont(name: "SFPro-Regular", size: 13)
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
            let image = UIImage(named: photosName[indexPath.row])
            viewController.image = image // передаем картинку внутрь singleView в свойство image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    
    // Метод вызывается когда пользователь нажимает на ячейку
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.showSingleImage, sender: indexPath)
    }
    
    // Динамический расчет высоты строки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

// MARK: UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    
    // Метод определяет количество строк в секции таблицы
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photosName.count
    }
    
    // Метод создает и настраивает ячейку для конкретной строки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) // 1 получаем ячейку из пула переиспользуемых ячеек
        
        guard let imageListCell = cell as? ImagesListCell else { // 2 Проверяем что она нужного типа
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath) // 3 Вызываем метод настройки
        
        return imageListCell // 4 Возвращаем получившуюся строку
    }
    // Метод вызывается прямо перед тем, как ячейка таблицы будет показана на экране
    func tableView(
      _ tableView: UITableView,
      willDisplay cell: UITableViewCell,
      forRowAt indexPath: IndexPath
    ) {
        if indexPath.row + 1 == photos.count{
            fetchPhotosNextPage()
        }
    }
    }

