//  AlertPresenter.swift
import UIKit

final class AlertPresenter{
    
    static let shared = AlertPresenter()
    private init() {}
    
    func showAlert(
        controller: UIViewController,
        title: String,
        message: String,
        preferredStyle: UIAlertController.Style,
        completion: (() -> Void)? = nil
    ){
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: preferredStyle
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .cancel){_ in
            completion?()
        })
        // Проверяем, активен ли входящий контроллер
        if controller.isViewLoaded && controller.view.window != nil {
            print("Алерт представлен через контроллер: \(controller)")
            controller.present(alert, animated: true)
        } else if let navController = controller.navigationController ?? controller.presentingViewController {
            print("Алерт представлен через: \(navController)")
            navController.present(alert, animated: true)
        } else {
            print("Не удалось найти UINavigationController или presentingViewController для \(controller)")
            // Запасной вариант: показ через корневой контроллер
            if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
               let rootVC = window.rootViewController {
                var topController = rootVC
                while let presentedVC = topController.presentedViewController {
                    topController = presentedVC
                }
                print("Алерт представлен через topController: \(topController)")
                topController.present(alert, animated: true)
            } else {
                print("Не удалось найти активный rootViewController")
            }
        }
    }
}
