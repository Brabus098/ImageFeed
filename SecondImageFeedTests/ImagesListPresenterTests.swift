//  ImagesListPresenterTests.swift

import XCTest
@testable import ImageFeed

final class ImagesListPresenterTests: XCTestCase {
    
    func testViewDidLoadCallsFetchPhotosNextPage() {
        let service = MockImageListService()
        let view = MockView()
        let presenter = ImagesListPresenter(view: view, imageListService: service)
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(service.fetchCalled, "fetchPhotosNextPage должен быть вызван")
    }
    
    func test_addCell_appendsNewPhotosAndReturnsIndexPaths() {
        let service = MockImageListService()
        let view = MockView()
        let presenter = ImagesListPresenter(view: view, imageListService: service)
        
        let photo = Photo(id: "1", size: CGSize(width: 100, height: 100),
                          createdAt: Date(),
                          welcomeDescription: "desc",
                          thumbImageURL: "thumb",
                          largeImageURL: "large",
                          isLiked: false)
        service.photos = [photo]
        
        let indexPaths = presenter.addCell()
        
        XCTAssertEqual(indexPaths.count, 1)
        XCTAssertEqual(presenter.photos.count, 1)
        XCTAssertEqual(indexPaths.first, IndexPath(row: 0, section: 0))
    }
    
    func test_didSelectImage_withValidURL_callsPresentSingleImageViewer() {
        let service = MockImageListService()
        let view = MockView()
        let presenter = ImagesListPresenter(view: view, imageListService: service)
        
        let photo = Photo(id: "1",
                          size: .zero,
                          createdAt: Date(),
                          welcomeDescription: "",
                          thumbImageURL: "",
                          largeImageURL: "https://example.com/image.jpg",
                          isLiked: false)
        presenter.photos = [photo]
        
        presenter.didSelectImage(at: IndexPath(row: 0, section: 0))
        
        XCTAssertTrue(view.didPresentViewer)
        XCTAssertEqual(view.presentedURL?.absoluteString, "https://example.com/image.jpg")
    }
    
    func test_toggleLike_success_updatesPhotoAndReloadsCell() {
        let service = MockImageListService()
        let view = MockView()
        let presenter = ImagesListPresenter(view: view, imageListService: service)
        
        let photo = Photo(id: "1", size: .zero,
                          createdAt: Date(),
                          welcomeDescription: "",
                          thumbImageURL: "",
                          largeImageURL: "",
                          isLiked: false)
        presenter.photos = [photo]
        
        let expectation = self.expectation(description: "like toggled")
        
        service.changeLikeResult = .success(())
        presenter.toggleLike(at: IndexPath(row: 0, section: 0))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(service.changeLikeCalled)
            XCTAssertTrue(view.didReloadCell)
            XCTAssertTrue(presenter.photos[0].isLiked)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_toggleLike_failure_doesNotCrashOrReload() {
        let service = MockImageListService()
        let view = MockView()
        let presenter = ImagesListPresenter(view: view, imageListService: service)
        
        let photo = Photo(id: "1", size: .zero, createdAt: Date(), welcomeDescription: "", thumbImageURL: "", largeImageURL: "", isLiked: false)
        presenter.photos = [photo]
        
        let expectation = self.expectation(description: "failure handled")
        
        service.changeLikeResult = .failure(NSError(domain: "", code: -1, userInfo: nil))
        presenter.toggleLike(at: IndexPath(row: 0, section: 0))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(service.changeLikeCalled)
            XCTAssertFalse(view.didReloadCell)
            XCTAssertFalse(presenter.photos[0].isLiked)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
