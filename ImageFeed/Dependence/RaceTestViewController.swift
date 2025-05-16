import UIKit

final class RaceTestViewController: UIViewController {
    private let oauthService = OAuth2Service.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let sameCodeButton = UIButton(type: .system)
        sameCodeButton.setTitle("Test Same Code", for: .normal)
        sameCodeButton.addTarget(self, action: #selector(testSameCode), for: .touchUpInside)
        
        let differentCodeButton = UIButton(type: .system)
        differentCodeButton.setTitle("Test Different Code", for: .normal)
        differentCodeButton.addTarget(self, action: #selector(testDifferentCode), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [sameCodeButton, differentCodeButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    @objc private func testSameCode() {
        print("🚀 Testing SAME code race condition")
        let code = "same_code"
        oauthService.fetchOAuthToken(code: code) { result in
            print("🟦 FIRST result: \(result)")
        }
        oauthService.fetchOAuthToken(code: code) { result in
            print("🟩 SECOND result: \(result)")
        }
    }

    @objc private func testDifferentCode() {
        print("🚀 Testing DIFFERENT code race condition")
        let firstCode = "code_1"
        let secondCode = "code_2"
        
        oauthService.fetchOAuthToken(code: firstCode) { result in
            print("🟥 FIRST result: \(result)")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.oauthService.fetchOAuthToken(code: secondCode) { result in
                print("🟧 SECOND result: \(result)")
            }
        }
    }
}
