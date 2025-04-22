//  SingleImageViewController.swift

import UIKit

final class SingleImageViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var displayedImageView: UIImageView!
    
    // Свойство вызываемое из другого контролерра для добавление актуальной картинки
    var image: UIImage? {
        didSet{ guard isViewLoaded, let image else { return }
            displayedImageView.image = image
            displayedImageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScrollZoom()
        setUpImage()
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton() {
        guard let image else { return }
        
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded() // Обновляем размеры scrollView
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        // Масштабирование изображения для заполнения экрана
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale))) // Растягиваем по большей стороне
        scrollView.setZoomScale(scale, animated: false)
        
        // Центрирование изображения
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let offsetX = max(0, (newContentSize.width - visibleRectSize.width) / 2)
        let offsetY = max(0, (newContentSize.height - visibleRectSize.height) / 2)
        scrollView.contentOffset = CGPoint(x: offsetX, y: offsetY)
    }
    
    private func setUpScrollZoom(){
        scrollView.minimumZoomScale = .minZoomScale
        scrollView.maximumZoomScale = .maxZoomScale
        scrollView.bounces = true
    }
    
    private func setUpImage(){
        if let newImage = image {
            displayedImageView.image = newImage
            displayedImageView.frame.size = newImage.size
            rescaleAndCenterImageInScrollView(image: newImage)
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
