//  MockImageListService.swift

import XCTest
@testable import ImageFeed

final class MockImageListService: ImageListServiceProtocol {
    var fetchCalled = false
    var changeLikeCalled = false
    var changeLikeResult: Result<Void, Error> = .success(())
    
    var photos: [Photo] = []
    
    func fetchPhotosNextPage() {
        fetchCalled = true
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        completion(changeLikeResult)
    }
    
    func photo(at index: Int) -> Photo {
        return photos[index]
    }
}
