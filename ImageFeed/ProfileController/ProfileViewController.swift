//  ProfileViewController.swift
//  ImageFeed

import UIKit

class ProfileViewController: UIViewController {
    
    // MARK: Property
    private var profileUiImage = UIImageView()
    private var profileNameLabel = UILabel()
    private var emailLabel = UILabel()
    private var statusLabel = UILabel()
    private var exitButton = UIButton()
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp(profileImage: profileUiImage, profileName: profileNameLabel, email: emailLabel, status: statusLabel, exitButton: exitButton)
    }
    
    // MARK: Action button
    func setUp(profileImage: UIImageView, profileName: UILabel, email: UILabel, status: UILabel, exitButton: UIButton){
        self.view.backgroundColor = .ypBlackIOS
        
        // Image
        let image = UIImage(named: "ProfilePhoto")
        profileImage.image = image
        
        self.view.addSubview(profileImage)
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.widthAnchor.constraint(equalTo: profileImage.heightAnchor),
            profileImage.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16)
        ])
        
        // Name
        profileName.text = "Екатерина Новикова"
        profileName.textColor = .ypWhiteIOS
        profileName.font = UIFont(name: "SFPro-Bold", size: 23)
        
        self.view.addSubview(profileName)
        profileName.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileName.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            profileName.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8)
        ])
        
        //email
        email.text = "@ekaterina_nov"
        email.textColor = .ypGrayIOS
        email.font = UIFont(name: "SFPro-Regular", size: 13)
        
        self.view.addSubview(email)
        email.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            email.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            email.topAnchor.constraint(equalTo: profileName.bottomAnchor, constant: 8)
        ])
        
        //status
        status.text = "Hello, world!"
        status.textColor = .ypWhiteIOS
        status.font = UIFont(name: "SFPro-Regular", size: 13)
        
        self.view.addSubview(status)
        status.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            status.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            status.topAnchor.constraint(equalTo: email.bottomAnchor, constant: 8)
        ])
        
        //ExitButton
        exitButton.tintColor = .ypRedIOS
        exitButton.setImage(UIImage(named: "Exit"), for: .normal)
        
        self.view.addSubview(exitButton)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            exitButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -26),
            exitButton.widthAnchor.constraint(equalToConstant: 24),
            exitButton.heightAnchor.constraint(equalTo: exitButton.widthAnchor)
            
        ])
    }
    
}
