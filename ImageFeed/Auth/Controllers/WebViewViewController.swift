//  WebViewViewController.swift
import UIKit
import WebKit

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

final class WebViewViewController: UIViewController & WebViewViewControllerProtocol {
    
    @IBOutlet weak var backItem: UINavigationItem!
    // MARK: Properties
    
    var presenter: WebViewPresenterProtocol?
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var progressView: UIProgressView!
    private var estimatedProgressObservation: NSKeyValueObservation?
    weak var delegate: WebViewViewControllerDelegate?
    
    
    // MARK: LifeCycle
    override func viewDidLoad(){
        super.viewDidLoad()

        webView.restorationIdentifier = "myWebView"
        setUpViews()
        webView.navigationDelegate = self
        presenter?.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            presenter?.didUpdateProgressValue(webView.estimatedProgress)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: Methods
    func setProgressValue(_ newValue: Float){
        progressView.progress = newValue
    }
    func setProgressHidden(_ isHidden: Bool){
        progressView.isHidden = isHidden
    }
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    private func setUpViews(){
        // Web
        webView.navigationDelegate = self // подписка на навигационного делегата
        // Progress
        progressView.progressTintColor = .ypBlackIOS
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            progressView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            progressView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
}
// MARK: WKNavigationDelegate
extension WebViewViewController: WKNavigationDelegate {
    // Метод обрабатывает переходы пользователя WebView и ищет код успешности
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    // Метод разбирает запрос по частям пытаясь найти сode
    private func code(from navigatorAction: WKNavigationAction) -> String? {
        if let url = navigatorAction.request.url {
            return presenter?.code(from: url)
        }
        return nil
    }
}
