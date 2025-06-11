import XCTest
import Foundation

@testable import ImageFeed // Замените на имя вашего модуля

// Мок для ProfileServiceProtocol
class MockProfileService: ProfileServiceProtocol {
    var profile: Profile?
}

// Мок для ShimmerProtocol
class MockShimmer: ShimmerProtocol {
    var showShimmerCalled = false
    var cleanLayersCalled = false
    var views: [UIView] = []
    var animationLayers = Set<CALayer>()


    func showShimmer(over view: UIView) {
        showShimmerCalled = true
        views.append(view)
        animationLayers.insert(CALayer())
    }

    func cleanLayers() {
        cleanLayersCalled = true
        animationLayers.forEach { gradient in
            gradient.removeFromSuperlayer()
        }
        animationLayers.removeAll()
    }
}

// Мок для LogoutServiceProtocol
class MockLogoutService: LogoutServiceProtocol {
    var logoutCalled = false

    func logout() {
        logoutCalled = true
    }
}

// Мок для HelperProtocol
class MockHelper: HelperProtocol {
    var logoutService: LogoutServiceProtocol?
    var imageStatus: ViewDownloadStatus = .someoneNoReady
    var labelsStatus: ViewDownloadStatus = .someoneNoReady
    var controller: ProfileViewControllerProtocol?
    var showOrHideShimmerCalled = false
    var goToExitCalled = false

    func showOrHideShimmer() {
        showOrHideShimmerCalled = true
    }

    func goToExit() {
        goToExitCalled = true
    }
}

// Мок для ProfileViewControllerProtocol
class MockProfileViewController: ProfileViewControllerProtocol {
    var profileService: ProfileServiceProtocol?
    var helper: HelperProtocol?
    var showShimmerCalled = false
    var hideShimmerCalled = false

    func showShimmer() {
        showShimmerCalled = true
    }

    func hideShimmer() {
        hideShimmerCalled = true
    }
    func confirmExit() {
        helper?.goToExit()
    }
}

// Тесты для ProfileViewController
class ProfileViewControllerTests: XCTestCase {
    var sut: ProfileViewController?
    var mockProfileService: MockProfileService?
    var mockShimmer: MockShimmer?
    var mockHelper: MockHelper?

    override func setUp() {
        super.setUp()
        mockProfileService = MockProfileService()
        mockShimmer = MockShimmer()
        mockHelper = MockHelper()
        sut = ProfileViewController(profileService: mockProfileService, shimmer: mockShimmer, helper: mockHelper)
    }

    override func tearDown() {
        sut = nil
        mockProfileService = nil
        mockShimmer = nil
        mockHelper = nil
        super.tearDown()
    }

    func testControllerInitialization() {
        // given
        let profileService = MockProfileService()
        let shimmer = MockShimmer()
        let helper = MockHelper()
        let controller = ProfileViewController(profileService: profileService, shimmer: shimmer, helper: helper)

        // when
        let _ = controller.view // Загружаем view для инициализации

        // then
        XCTAssertNotNil(controller.profileService, "ProfileService should be initialized")
        XCTAssertNotNil(controller.shimmer, "Shimmer should be initialized")
        XCTAssertNotNil(controller.helper, "Helper should be initialized")
    }

    func testControllerViewDidLoad_SetupUIElements() {
        // given
        guard let controller = sut else { return }
        let mockProfileService = MockProfileService()
        controller.profileService = mockProfileService

        // when
        controller.loadViewIfNeeded()

        // then
        XCTAssertTrue(controller.view.subviews.contains(where: { $0 is UIImageView }), "ProfileImageView should be added")
        XCTAssertTrue(controller.view.subviews.contains(where: { $0 is UILabel }), "Labels should be added")
        XCTAssertTrue(controller.view.subviews.contains(where: { $0 is UIButton }), "LogoutButton should be added")
    }

    func testControllerViewDidLoad_UpdateProfileDetails() {
        // given
        guard let controller = sut, let mockHelper = mockHelper else { return }
        let profile = Profile(userName: "@test", name: "Test Name", loginName: "@test", bio: "Test Bio")
        mockProfileService?.profile = profile

        // when
        controller.loadViewIfNeeded()

        // then
        XCTAssertEqual(mockHelper.labelsStatus, .labelsIsReady, "Helper labelsStatus should be updated")
    }

    func testControllerUpdateProfileDetails() {
        // given
        guard let controller = sut, let mockHelper = mockHelper else { return }
        let profile = Profile(userName: "@john", name: "John Doe", loginName: "@john", bio: "Hello")
        controller.loadViewIfNeeded() // Загружаем view для инициализации UI

        // when
        controller.updateProfileDetails(profile: profile)

        // then
        XCTAssertEqual(mockHelper.labelsStatus, .labelsIsReady, "Helper labelsStatus should be set to .labelsIsReady")
        // Поскольку свойства private, прямой доступ невозможен. Проверяем косвенно через поведение.
    }

    func testControllerShowShimmer() {
        // given
        guard let controller = sut, let mockShimmer = mockShimmer else { return }
        controller.loadViewIfNeeded()

        // when
        controller.showShimmer()

        // then
        XCTAssertTrue(mockShimmer.showShimmerCalled, "Shimmer's showShimmer should be called")
        XCTAssertEqual(mockShimmer.views.count, 4, "Shimmer should be applied to 4 views")
    }

    func testControllerHideShimmer() {
        // given
        guard let controller = sut, let mockShimmer = mockShimmer else { return }

        // when
        controller.hideShimmer()

        // then
        XCTAssertTrue(mockShimmer.cleanLayersCalled, "Shimmer's cleanLayers should be called")
    }

    func testControllerExitAction() {
        // given
        guard let controller = sut, let mockHelper = mockHelper else { XCTFail("SUT или mockHelper is nil"); return }
//        controller.loadViewIfNeeded()

        // when
        controller.confirmExit()
        
        // then
        XCTAssertTrue(mockHelper.goToExitCalled, "Helper's goToExit should be called")
    }
}

// Тесты для Helper
class HelperTests: XCTestCase {
    var sut: Helper?
    var mockController: MockProfileViewController?
    var mockLogoutService: MockLogoutService?

    override func setUp() {
        super.setUp()
        mockController = MockProfileViewController()
        mockLogoutService = MockLogoutService()
        sut = Helper(logoutService: mockLogoutService, controller: mockController!)
    }

    override func tearDown() {
        sut = nil
        mockController = nil
        mockLogoutService = nil
        super.tearDown()
    }

    func testHelperShowOrHideShimmerWhenBothReady() {
        // given
        guard let helper = sut, let mockController = mockController else { return }
        helper.imageStatus = .imageIsReady
        helper.labelsStatus = .labelsIsReady

        // when
        helper.showOrHideShimmer()

        // then
        XCTAssertTrue(mockController.hideShimmerCalled, "hideShimmer should be called when both are ready")
        XCTAssertFalse(mockController.showShimmerCalled, "showShimmer should not be called")
    }

    func testHelperShowOrHideShimmerWhenNotReady() {
        // given
        guard let helper = sut, let mockController = mockController else { return }
        helper.imageStatus = .someoneNoReady
        helper.labelsStatus = .someoneNoReady

        // when
        helper.showOrHideShimmer()

        // then
        XCTAssertTrue(mockController.showShimmerCalled, "showShimmer should be called when not ready")
        XCTAssertFalse(mockController.hideShimmerCalled, "hideShimmer should not be called")
    }

    func testHelperGoToExit() {
        // given
        guard let helper = sut, let mockLogoutService = mockLogoutService else { return }

        // when
        helper.goToExit()

        // then
        XCTAssertTrue(mockLogoutService.logoutCalled, "LogoutService's logout should be called")
    }
}

// Тесты для Shimmer
class ShimmerTests: XCTestCase {
    var sut: Shimmer?
    var testView: UIView?

    override func setUp() {
        super.setUp()
        sut = Shimmer()
        testView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    }

    override func tearDown() {
        sut = nil
        testView = nil
        super.tearDown()
    }

    func testShimmerShowShimmer() {
        // given
        guard let shimmer = sut, let view = testView else { return }

        // when
        shimmer.showShimmer(over: view)

        // then
        XCTAssertEqual(shimmer.animationLayers.count, 1, "One layer should be added")
        XCTAssertTrue(view.layer.sublayers?.contains(shimmer.animationLayers.first!) ?? false, "Layer should be added to view")
    }

    func testShimmerCleanLayers() {
        // given
        guard let shimmer = sut, let view = testView else { XCTFail("SUT or testView is nil"); return }
        shimmer.showShimmer(over: view)

        // when
        shimmer.cleanLayers()

        // then
        XCTAssertEqual(shimmer.animationLayers.count, 0, "All layers should be removed")
        XCTAssertTrue(view.layer.sublayers?.isEmpty ?? true, "No sublayers should remain on view")
    }
}
