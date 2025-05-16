//  WebViewViewController.swift
import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var progressView: UIProgressView!
    private var estimatedProgressObservation: NSKeyValueObservation?
    weak var delegate: WebViewViewControllerDelegate?
    private enum WebViewConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    }
    // MARK: LifeCycle
    override func viewDidLoad(){
        super.viewDidLoad()
        setUpViews()
        loadAuthView()
        updateProgress()
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }
                 self.updateProgress()
             })
    }
    // MARK: Methods
    // Метод формирует запрос для загрузки страницы co входом в систему
    private func loadAuthView(){
        guard var urlComponents =  URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("Ошибка базовой ссылки")
            return }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        guard let url = urlComponents.url else {
            print("Ошибка в сборной авторизационной ссылки")
            return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    private func updateProgress(){
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
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
        if let code = code(from: navigationAction) { // проверяем наличие успешного перехода с значением  "code"
            delegate?.webViewViewController(self, didAuthenticateWithCode: code) // -> оповещаем делегата об успешно полученном коде
            decisionHandler(.cancel)
        } else {
            
            decisionHandler(.allow)
        }
    }
    // Метод разбирает запрос по частям пытаясь найти сode
    private func code(from navigatorAction: WKNavigationAction) -> String? {
        if
            let url = navigatorAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItems = items.first(where: {$0.name == "code"})
        {
            return codeItems.value
        } else {
            return nil
        }
    }
}
