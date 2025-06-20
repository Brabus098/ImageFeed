import UIKit

final class TabBarController: UITabBarController {

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTabBar()
    }

    private func setupTabBar() {
        // MARK: - ImagesList
        let imagesListService = ImagesListService()
        let imagesListPresenter = ImagesListPresenter(view: nil, imageListService: imagesListService)
        let imagesListVC = ImagesListViewController(presenter: imagesListPresenter)
        imagesListPresenter.view = imagesListVC

        imagesListVC.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "TabSecond_No_Active"),
            selectedImage: UIImage(named: "TabFirst_Active")
        )

        // MARK: - Profile (заглушка)
        let profileVC = ProfileViewController(profileService: ProfileService.shared,
                                              shimmer: Shimmer())
        let helper = Helper(logoutService: ProfileLogoutService.shared, controller: profileVC)
        profileVC.helper = helper
        
        profileVC.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "No_Active"),
            selectedImage: UIImage(named: "super_Active")
        )

        // MARK: - Add ViewControllers to TabBar
        self.viewControllers = [imagesListVC, profileVC]
    }
}
