//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Владимир on 10.06.2025.
//
import Foundation

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?
    private let imageListService: ImageListServiceProtocol
    var photos: [Photo] = []

    init(view: ImagesListViewProtocol?, imageListService: ImageListServiceProtocol) {
        self.view = view
        self.imageListService = imageListService
    }

    func viewDidLoad() {
        imageListService.fetchPhotosNextPage()
    }

    func addCell() -> [IndexPath] {
        let oldCount = photos.count
        let newCount = imageListService.photos.count
        var indexPaths: [IndexPath] = []

        if oldCount != newCount {
            for i in oldCount..<newCount {
                indexPaths.append(IndexPath(row: i, section: 0))
                photos.append(imageListService.photo(at: i))
            }
        }
        return indexPaths
    }

    func didSelectImage(at indexPath: IndexPath) {
        let urlString = photos[indexPath.row].largeImageURL
        guard let url = URL(string: urlString) else { return }
        view?.presentSingleImageViewer(with: url)
    }

    func toggleLike(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]

        imageListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                let updatedPhoto = Photo(
                    id: photo.id,
                    size: photo.size,
                    createdAt: photo.createdAt,
                    welcomeDescription: photo.welcomeDescription,
                    thumbImageURL: photo.thumbImageURL,
                    largeImageURL: photo.largeImageURL,
                    isLiked: !photo.isLiked
                )
                self.photos[indexPath.row] = updatedPhoto
                DispatchQueue.main.async {
                    self.view?.reloadCell(at: indexPath, isLiked: !photo.isLiked)
                }
            case .failure:
                break // можно добавить алерт через view
            }
        }
    }
}
