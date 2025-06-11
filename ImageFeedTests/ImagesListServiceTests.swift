//  ImageFeedTests.swift

@testable import ImageFeed
import XCTest

final class ImageListServiceTest: XCTestCase {
    
    func testFetchingTwoPages() {
        let service = ImagesListService()
        let expectation1 = expectation(description: "First page loaded")
        let expectation2 = expectation(description: "Second page loaded")
        
        var notificationsReceived = 0
        
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: service,
            queue: .main
        ) { result in
            notificationsReceived += 1
            
            if notificationsReceived == 1 {
                expectation1.fulfill()
                // Загружаем вторую страницу только после первой
                service.fetchPhotosNextPage()
            } else if notificationsReceived == 2 {
                expectation2.fulfill()
            }
        }
        
        service.fetchPhotosNextPage()
        
        wait(for: [expectation1, expectation2], timeout: 10.0)
        XCTAssertEqual(service.photos.count, 20)
    }
}
