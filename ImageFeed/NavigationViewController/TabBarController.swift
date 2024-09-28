//  TabBarController.swift
import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib(){
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imageListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(title: "",
                                                        image: UIImage(named: "No_Active"),
                                                        selectedImage:UIImage(named: "super_Active"))
        
        self.viewControllers = [imageListViewController, profileViewController]
    }
}
