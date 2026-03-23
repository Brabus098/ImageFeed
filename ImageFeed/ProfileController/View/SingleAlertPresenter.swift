//  SingleAlertPresenter.swift

import UIKit

final class SingleAlertPresenter {
    
    static let shared = SingleAlertPresenter()
    private init(){}
    
    enum AlertMode{
        case one
        case dual
    }
    
    func showAlert(presentIn controller: UIViewController,
                   title: String,
                   optionalMessage: String?,
                   firstActionWithTitle: String,
                   firstActionWithStyle: UIAlertAction.Style,
                   firstCompetition: (() -> Void)?,
                   optionalActionTitle: String?,
                   optionalStyleForSecondAction: UIAlertAction.Style?,
                   secondCompetition: (() -> Void)?,
                   mode: AlertMode
                   
    ){
        let alert = UIAlertController(title: title,
                                      message: optionalMessage ?? "",
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: firstActionWithTitle, style: firstActionWithStyle) {_ in firstCompetition?()}
        
        let secondAction = UIAlertAction(title: optionalActionTitle,
                                         style: optionalStyleForSecondAction ?? .default) { _ in secondCompetition?()}
        
        if mode == .one { alert.addAction(action) }
        else {
            alert.addAction(action)
            alert.addAction(secondAction)
        }
        controller.present(alert,animated: true)
    }
}
