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
                                                                             queue: .main,
                                                                             using: { [weak self] _ in
            guard let self = self else { return } // Проверка на существование ProfileViewController
            self.updateAvatar()
        })
        updateAvatar()
    }
    
    // MARK: Methods
    // Метод обновляет данные профиля
    private func updateAvatar(){
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let imageUrl = URL(string: profileImageURL),
            let placeHolderImage = UIImage(named: "PlaceHolderForProfileImage")
        else { return }
        profileImageView.backgroundColor = .clear
        let processor = RoundCornerImageProcessor(cornerRadius: 61, backgroundColor: .clear)
        profileImageView.kf.setImage(with: imageUrl,
                                     placeholder: placeHolderImage,
                                     options: [.processor(processor)])
    }
    // Метод обновляет фото профиля
    private func updateProfileDetails(profile: Profile){
        self.nameLabel.text = profile.name
        self.statusLabel.text = profile.bio
        self.usernameLabel.text = profile.loginName
    }
    
    private func addSubview(_ subview: UIView) {
        view.addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setUpImage(profileImage: UIImageView){
        self.view.backgroundColor = .ypBlackIOS
        
        let image = UIImage(named: "ProfilePhoto")
        profileImage.image = image
        
        addSubview(profileImage)
        
        NSLayoutConstraint.activate([
            profileImage.heightAnchor.constraint(equalToConstant: ConstantsProfile.avatarSize),
            profileImage.widthAnchor.constraint(equalTo: profileImage.heightAnchor),
            profileImage.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: ConstantsProfile.topInset),
            profileImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: ConstantsProfile.sideInset)
        ])}
    
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
        
        addSubview(exitButton)
        
        NSLayoutConstraint.activate([
            exitButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: ConstantsProfile.trailingInsert),
            exitButton.widthAnchor.constraint(equalToConstant: ConstantsProfile.exitWidt),
            exitButton.heightAnchor.constraint(equalTo: exitButton.widthAnchor)
        ])
    }
}
