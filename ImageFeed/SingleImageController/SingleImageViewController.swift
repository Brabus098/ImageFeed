//  SingleImageViewController.swift

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var displayedImageView: UIImageView!
    private let splash = UIImage(named: "SplashForBigImage")
    
    // Свойство вызываемое из другого контролерра для добавление актуальной картинки
    var imageURL: URL? {
        didSet{
            loadImage()
        }
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScrollZoom()
        loadImage()
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton() {
        let image = displayedImageView.image
        guard let image else { return }
        
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        // 1. Сбрасываем zoom scale
        scrollView.setZoomScale(1.0, animated: false)
        
        // 2. Устанавливаем размер UIImageView равным размеру изображения
        displayedImageView.frame = CGRect(origin: .zero, size: image.size)
        scrollView.contentSize = image.size
        
        // 3. Вычисляем масштаб
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(scrollView.maximumZoomScale, max(scrollView.minimumZoomScale, max(hScale, vScale)))
        
        // 4. Применяем масштаб
        scrollView.setZoomScale(scale, animated: false)
        
        // 5. Центрируем изображение
        scrollView.layoutIfNeeded()
        let offsetX = max(0, (scrollView.contentSize.width - visibleRectSize.width) / 2)
        let offsetY = max(0, (scrollView.contentSize.height - visibleRectSize.height) / 2)
        scrollView.contentOffset = CGPoint(x: offsetX, y: offsetY)
    }
    
    private func setUpScrollZoom(){
        scrollView.minimumZoomScale = .minZoomScale
        scrollView.maximumZoomScale = .maxZoomScale
        scrollView.bounces = true
    }
    
    private func loadImage() {
        guard let imageURL, isViewLoaded else { return }
        
        UIBlockingProgressHUD.show()
        
        // Показываем сплэш загрузки
        guard let splash else { return }
        displayedImageView.frame = CGRect(x: 0, y: 0, width: 83, height: 75)
        displayedImageView.image = splash
        displayedImageView.center = view.center
        
        displayedImageView.kf.setImage(with: imageURL,
                                       placeholder: UIImage(named: "SplashForBigImage")) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success(let value):
                self.displayedImageView.image = value.image
                DispatchQueue.main.async {
                    self.rescaleAndCenterImageInScrollView(image: value.image)
                }
            case .failure(let error):
                print("Ошибка загрузки: \(error)")
                DispatchQueue.main.async {
                    self.showError()
                }
            }
        }
    }
}

// MARK: UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    // Метод позволяет пользователю вручную увеличивать или уменьшать изображение
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return displayedImageView
    }
    // Метод возвращает картинку к центру при уменьшении
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with: UIView?, atScale: CGFloat){
        let visibleRectSize = scrollView.bounds.size
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        // Вычисляем отступы для центрирования
        let insetX = max(0, (visibleRectSize.width - newContentSize.width) / 2)
        let insetY = max(0, (visibleRectSize.height - newContentSize.height) / 2)
        scrollView.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
    }
}

private extension CGFloat {
    static let minZoomScale: CGFloat = 0.1
    static let maxZoomScale: CGFloat = 1.25
}

extension SingleImageViewController{
    private func showError(){
        SingleAlertPresenter.shared.showAlert(presentIn: self,
                                              title: "Что-то пошло не так. Попробовать ещё раз?",
                                              optionalMessage: nil,
                                              firstActionWithTitle: "Не надо",
                                              firstActionWithStyle: .cancel,
                                              firstCompetition: nil,
                                              optionalActionTitle: "Повторить",
                                              optionalStyleForSecondAction: .default,
                                              secondCompetition: {
            self.loadImage() // TODO: заменить на LOAD потом удалить loadImageWithKf
        }, mode: .dual)
    }
}
