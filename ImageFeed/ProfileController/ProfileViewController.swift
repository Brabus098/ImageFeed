//  ProfileViewController.swift

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: Properties
    private var profileImageView = UIImageView()
    private var profileImageServiceObserver: NSObjectProtocol?
    private var nameLabel = UILabel()
    private var usernameLabel = UILabel()
    private var statusLabel = UILabel()
    private var logoutButton = UIButton()
    private var profileService = ProfileService.shared
    private var shimmerPlaceholders: [ShimmerView] = []
    private var animationLayers = Set<CALayer>()
    private var imageStatus: ViewDownloadStatus = .someoneNoReady
    private var labelsStatus: ViewDownloadStatus = .someoneNoReady

    private enum ViewDownloadStatus{
        case imageIsReady
        case labelsIsReady
        case someoneNoReady
    }
    
    private enum ConstantsProfile {
        static let avatarSize: CGFloat = 70
        static let sideInset: CGFloat = 16
        static let topInset: CGFloat = 32
        static let nameFontSize: CGFloat = 23
        static let middleInsert: CGFloat = 8
        static let secondaryFontSize: CGFloat = 13
        static let exitWidt: CGFloat = 24
        static let trailingInsert: CGFloat = -26
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpImage(profileImage:profileImageView)
        setUpProfileName(profileName: nameLabel, profileImage: profileImageView)
        setUpEmail(email: usernameLabel, profileName: nameLabel, profileImage: profileImageView)
        setUpStatus(email: usernameLabel, status: statusLabel, profileImage: profileImageView)
        setUpExitButton(exitButton: logoutButton, profileImage: profileImageView)
       
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
        }
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(forName: ProfileImageService.didChangeNotification,
                                                                             object: nil,
                                                                             queue: nil,
                                                                             using: { [weak self] _ in
            guard let self = self else { return } // Проверка на существование ProfileViewController
            self.updateAvatar()
        })
        
       // Обновление аватарки
       updateAvatar()
     }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
    }
    
    override func viewIsAppearing(_ animated:Bool) {
        super.viewIsAppearing(animated)
        if imageStatus != .imageIsReady || labelsStatus != .labelsIsReady {
            
                       self.showShimmer(over: self.profileImageView)
                       self.showShimmer(over: self.usernameLabel)
                       self.showShimmer(over: self.statusLabel)
                       self.showShimmer(over: self.nameLabel)
                   
        } else if imageStatus == .imageIsReady || labelsStatus == .labelsIsReady{
            downloadStatusFor(image: imageStatus, labels: labelsStatus)
        }
    }
    // MARK: Methods
    // Метод обновляет данные профиля
    private func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
              let imageUrl = URL(string: profileImageURL),
              let placeHolderImage = UIImage(named: "PlaceHolderForProfileImage") else {
            return
        }
            self.profileImageView.backgroundColor = .clear
            let processor = RoundCornerImageProcessor(cornerRadius: 61, backgroundColor: .clear)
            self.profileImageView.kf.setImage(with: imageUrl,
                                       placeholder: placeHolderImage,
                                       options: [.processor(processor)]) { _ in
                self.imageStatus = .imageIsReady
                self.downloadStatusFor(image: self.imageStatus, labels: self.labelsStatus)
        }
    }
    // Метод обновляет фото профиля
    private func updateProfileDetails(profile: Profile){
        self.nameLabel.text = profile.name
        self.statusLabel.text = profile.bio
        self.usernameLabel.text = profile.loginName
        labelsStatus = .labelsIsReady
    }
    
    private func downloadStatusFor(image: ViewDownloadStatus, labels: ViewDownloadStatus){
            hideAllShimmers(animationSet: animationLayers)
    }
    
    private func addSubview(_ subview: UIView) {
        view.addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setUpImage(profileImage: UIImageView){
        self.view.backgroundColor = .ypBlackIOS
        
        let image = UIImage(named: "ProfilePhoto")
        profileImage.image = image
        profileImage.backgroundColor = UIColor.clear
        
        addSubview(profileImage)
        
        NSLayoutConstraint.activate([
            profileImage.heightAnchor.constraint(equalToConstant: ConstantsProfile.avatarSize),
            profileImage.widthAnchor.constraint(equalTo: profileImage.heightAnchor),
            profileImage.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: ConstantsProfile.topInset),
            profileImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: ConstantsProfile.sideInset)
        ])
    }
    
    private func setUpProfileName(profileName: UILabel, profileImage: UIImageView){
        profileName.text = "Екатерина Новикова"
        profileName.textColor = .ypWhiteIOS
        profileName.font = UIFont(name: "SFPro-Bold", size: ConstantsProfile.nameFontSize)
        
        addSubview(profileName)
        
        NSLayoutConstraint.activate([
            profileName.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            profileName.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: ConstantsProfile.middleInsert)
        ])
    }
    private func setUpEmail(email: UILabel, profileName: UILabel, profileImage: UIImageView ){
        email.text = "@ekaterina_nov"
        email.textColor = .ypGrayIOS
        email.font = UIFont(name: "SFPro-Regular", size: ConstantsProfile.secondaryFontSize)
        
        addSubview(email)
        
        NSLayoutConstraint.activate([
            email.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            email.topAnchor.constraint(equalTo: profileName.bottomAnchor, constant: ConstantsProfile.middleInsert)
        ])
    }
    private func setUpStatus(email: UILabel, status: UILabel, profileImage: UIImageView){
        status.text = "Hello, world!"
        status.textColor = .ypWhiteIOS
        status.font = UIFont(name: "SFPro-Regular", size: ConstantsProfile.secondaryFontSize)
        
        addSubview(status)
        
        NSLayoutConstraint.activate([
            status.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            status.topAnchor.constraint(equalTo: email.bottomAnchor, constant: ConstantsProfile.middleInsert)
        ])
    }
    
    private func setUpExitButton(exitButton: UIButton, profileImage: UIImageView){
        exitButton.tintColor = .ypRedIOS
        exitButton.setImage(UIImage(named: "Exit"), for: .normal)
        exitButton.addTarget(self, action: #selector(exitAction), for: .touchUpInside)
    
        addSubview(exitButton)

        NSLayoutConstraint.activate([
            exitButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: ConstantsProfile.trailingInsert),
            exitButton.widthAnchor.constraint(equalToConstant: ConstantsProfile.exitWidt),
            exitButton.heightAnchor.constraint(equalTo: exitButton.widthAnchor)
        ])
    }
    
    private func showShimmer(over view: UIView) {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.locations = [0, 0.1, 0.3]
        
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = view.frame.height / 2
        gradient.masksToBounds = true

        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
        
        animationLayers.insert(gradient)
        view.layer.addSublayer(gradient)
    }
    
    private func hideAllShimmers(animationSet:  Set<CALayer>) {
        animationLayers.forEach { gradient in
            gradient.removeFromSuperlayer()
        }
    }
    
    @objc private func exitAction(){
        
        SingleAlertPresenter.shared.showAlert(presentIn: self,
                                              title: "Пока, пока!",
                                              optionalMessage: "Уверенны что хотите выйти?",
                                              firstActionWithTitle: "Нет",
                                              firstActionWithStyle: .default,
                                              firstCompetition: nil,
                                              optionalActionTitle: "Да",
                                              optionalStyleForSecondAction: .cancel,
                                              secondCompetition: {
            ProfileLogoutService.shared.logout()
            let rootController = SplashViewController()
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("Invalid window configuration")
                return
            }
            window.rootViewController = rootController
        },
                                              mode: .dual)
    }
}
