//  SecondImageFeedTests.swift

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
        //given
        let webViewController = webViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        webViewController.presenter = presenter
        presenter.view = webViewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(webViewController.loadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne(){
        
        //given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let testValue: Float = 0.6
        
        //when
        let result = presenter.shouldHideProgress(for: testValue)
        
        //then
        XCTAssertFalse(result)
    }
    
    func testProgressHiddenWhenOne(){
        //given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let testValue: Float = 1
        
        //when
        let result = presenter.shouldHideProgress(for: testValue)
        
        //then
        XCTAssertTrue(result)
    }
    
    func testAuthHelperAuthURL(){
        //given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        //when
        let url = authHelper.authURL()
        
        guard let urlString = url?.absoluteString else {
            XCTFail("Auth URL is nil")
            return
        }
        
        //then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    func testCodeFromURL(){
        //given
        var components = URLComponents(string: "https://unsplash.com/oauth/authorize/native")
        components?.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let authHelper = AuthHelper()
        var result: String?
        
        //when
        if let component = components?.url {
            result = authHelper.code(from: component)
        }
        
        //then
        XCTAssertEqual("test code", result)
    }
}

