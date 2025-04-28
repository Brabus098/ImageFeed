//  SplashViewController.swift

import UIKit

final class SplashViewController: UIViewController {
  
    // MARK: Properties
    private let storage = OAuth2TokenStorage()
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAuth()
    }
    
    // MARK: Methods
    private func checkAuth(){ // Проверяем наличие существующего токена
        if storage.token != nil {
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: "Navigator", sender: nil)
        }
    }
    // Метод стирает предидущие экраны и устанавливает корневой
    private func switchToTabBarController() {
        // Получаем экземпляр `window` приложения
        guard let window = UIApplication.shared.windows.first else {
            
            assertionFailure("Invalid window configuration")
            return
        }
        // Создаём экземпляр нужного контроллера из Storyboard с помощью ранее заданного идентификатора
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        // Установим в `rootViewController` полученный контроллер
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Navigator" {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for AuthenticationScreenSegue")
                return
            }
            viewController.delegate = self // Установим делегатом входного контроллера  SplashViewController
        } else {
            super.prepare(for: segue, sender: sender)
           }
    }
}
// Реагируем на успешное получение токена
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        switchToTabBarController()
    }
}
