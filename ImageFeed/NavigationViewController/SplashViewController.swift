//  SplashViewController.swift

import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: Properties
    private let storage = KeychainStorage()
    private let secondStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileController = ProfileViewController()
    private let profileImageService = ProfileImageService.shared
    private let logoImageView = UIImageView()
    private let splashScreenLogo = UIImage(named: "splash_screen_logo")
    
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpViews()
        checkAuth()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //storage.tokenDelete вычисляемое свойство обнуляющее токен в 
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpViews()
    }
    
    // MARK: Methods
    private func setUpViews(){
        guard let logo = splashScreenLogo else{ return }
        
        self.view.backgroundColor = .ypBlackIOS
        
        self.view.addSubview(logoImageView)
        logoImageView.image = logo
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 75),
            logoImageView.widthAnchor.constraint(equalToConstant: 73)
        ])
    }
    
    private func checkAuth(){
        if let token = storage.token { // Проверяем наличие существующего токена
            fetchProfile(token)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let identifier = storyboard.instantiateViewController(withIdentifier: "NavigationController")
            
            guard let navController = identifier as? UINavigationController else { return }
            
            let authVC = navController.viewControllers.first as? AuthViewController
            authVC?.delegate = self
            navController.modalPresentationStyle = .fullScreen
            DispatchQueue.main.async {
                self.present(navController, animated: true)
            }
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
        // Устанавлиаваем в `rootViewController` подключенный контроллер
        window.rootViewController = tabBarController
    }
}
// Реагируем на успешное получение токена
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        guard let token = storage.token else {
            return
        }
        fetchProfile(token)
    }
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let result):
                self.profileImageService.fetchProfileImageURL(userName: result.userName) {_ in }
                self.switchToTabBarController()
            case .failure:
                break
            }
        }
    }
}
