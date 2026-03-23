//  WebViewTests.swift

@testable import ImageFeed
import XCTest
import Foundation

final class WebViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad(){
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest(){
        let webViewController = webViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        webViewController.presenter = presenter
        presenter.view = webViewController
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(webViewController.loadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne(){
        
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let testValue: Float = 0.6
        
        let result = presenter.shouldHideProgress(for: testValue)
        
        XCTAssertFalse(result)
    }
    
    func testProgressHiddenWhenOne(){
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let testValue: Float = 1
        
        let result = presenter.shouldHideProgress(for: testValue)
        
        XCTAssertTrue(result)
    }
    
    func testAuthHelperAuthURL(){
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        let url = authHelper.authURL()
        
        guard let urlString = url?.absoluteString else {
            XCTFail("Auth URL is nil")
            return
        }
        
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromURL(){
        var components = URLComponents(string: "https://unsplash.com/oauth/authorize/native")
        components?.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let authHelper = AuthHelper()
        var result: String?
        
        if let component = components?.url {
            result = authHelper.code(from: component)
        }
        
        XCTAssertEqual("test code", result)
    }
}

