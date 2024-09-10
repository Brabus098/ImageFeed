//  AuthViewController.swift

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    
    // MARK: Properties
    private let logoImageView = UIImageView()
    @IBOutlet private weak var enterButton: UIButton!
    private let identifierForView = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    weak var delegate: AuthViewControllerDelegate?

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        enterButton.titleLabel?.font = UIFont(name: "SFPro-Bold", size: 17)
    }
    
    // MARK: Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == identifierForView {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(identifierForView)")
                return
            }
            webViewViewController.delegate = self 
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func setUpViews(){
        // View
        view.backgroundColor = .ypBlackIOS
        
        // Logo
        let logo = UIImage(named: "Logo_of_Unsplash")
        logoImageView.image = logo
        
        view.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Button
        self.enterButton.setTitle("Войти", for: .normal)
        self.enterButton.setTitleColor(.ypBlackIOS, for: .normal)
        self.enterButton.layer.masksToBounds = true
        self.enterButton.layer.cornerRadius = 16
        
        view.addSubview(enterButton)
        enterButton.translatesAutoresizingMaskIntoConstraints = false
        
        // NavigationController
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "Backward")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "Backward")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black (iOS)")
        
        // Constraint
        NSLayoutConstraint.activate([
            logoImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            logoImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            enterButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: ButtonConstants.leftInset),
            enterButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: ButtonConstants.rightInset),
            enterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: ButtonConstants.bottomInsert),
            enterButton.heightAnchor.constraint(equalToConstant: ButtonConstants.buttonHeight),
            enterButton.centerXAnchor.constraint(equalTo: logoImageView.centerXAnchor)
        ])
    }
    
    private enum ButtonConstants {
        static let bottomInsert: CGFloat = -90
        static let rightInset: CGFloat = -16
        static let leftInset: CGFloat = 16
        static let buttonHeight: CGFloat = 48
     
    }

    // MARK: webViewViewControllerDelegate
    // Метод создает POST запрос и отправляет в сеть
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        let optionalUrl = oauth2Service.makeOAuthTokenRequest(code: code)
        if let urlRequest = optionalUrl {
            oauth2Service.fetchOAuthToken(code: urlRequest) { request in
                self.delegate?.didAuthenticate(self)
            }
        }
    }
}
