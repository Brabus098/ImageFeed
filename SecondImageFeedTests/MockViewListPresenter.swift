//  MockViewListPresenter.swift

import XCTest
@testable import ImageFeed

final class MockView: ImagesListViewProtocol {
    var didReloadCell = false
    var didPresentViewer = false
    var presentedURL: URL?

    func updatesTableViewAnimated(oldCount: Int, newCount: Int) {}

    func reloadCell(at indexPath: IndexPath, isLiked: Bool) {
        didReloadCell = true
    }

    func presentSingleImageViewer(with url: URL) {
        didPresentViewer = true
        presentedURL = url
    }
}
