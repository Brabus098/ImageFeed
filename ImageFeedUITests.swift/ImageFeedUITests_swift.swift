import XCTest

class AuthUITests: XCTestCase {
    
    private let app = XCUIApplication()
    private let email = "" // MAIL IS HERE
    private let password = "" // PASS HERE
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuthFlow() {
        // 1. Нажать кнопку авторизации
        tapAuthButton()
        
        // 2. Подождать загрузки экрана авторизации
        let authScreen = waitForAuthScreen()
        
        // 3. Ввести email и пароль
        enterCredentials(in: authScreen)
        
        // 4. Нажать кнопку логина
        tapLoginButton(in: authScreen)
        
        // 5. Подождать открытия экрана ленты
        waitForFeedScreen()
    }
    
    // MARK: - Шаг 1: Нажатие кнопки авторизации
    private func tapAuthButton() {
        let authButton = app.buttons["Войти"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 10),
                     "Кнопка 'Войти' не найдена на экране")
        authButton.tap()
        print("Нажата кнопка авторизации")
    }
    
    // MARK: - Шаг 2: Ожидание экрана авторизации
    private func waitForAuthScreen() -> XCUIElement {
        let authScreen = app.webViews.firstMatch
        XCTAssertTrue(authScreen.waitForExistence(timeout: 15),
                     "Экран авторизации не загрузился")
        print("Экран авторизации успешно загружен")
        return authScreen
    }
    
    // MARK: - Шаг 3: Ввод учетных данных
    private func enterCredentials(in authScreen: XCUIElement) {
        // Ввод email
        let emailField = authScreen.textFields.firstMatch
        XCTAssertTrue(emailField.waitForExistence(timeout: 8),
                     "Поле для email не найдено")
        emailField.tap()
        emailField.typeText(email)
        print("Введен email: \(email)")
        
        // Переход к полю пароля
        authScreen.tap() // Скрываем клавиатуру
        usleep(300_000) // пауза
        
        // Ввод пароля
        let passwordField = authScreen.secureTextFields.firstMatch
        XCTAssertTrue(passwordField.waitForExistence(timeout: 8),
                     "Поле для пароля не найдено")
        passwordField.tap()
        slowType(text: password, element: passwordField)
        print("Введен пароль")
        
        // Проверка введенных данных
        if let enteredEmail = emailField.value as? String {
            XCTAssertEqual(enteredEmail, email, "Введенный email не совпадает")
        }
    }
    
    // MARK: - Шаг 4: Нажатие кнопки логина
    private func tapLoginButton(in authScreen: XCUIElement) {
        let loginButton = authScreen.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 8),
                     "Кнопка 'Login' не найдена")
        loginButton.tap()
        print("Нажата кнопка входа")
    }
    
    // MARK: - Шаг 5: Ожидание экрана ленты
    private func waitForFeedScreen() {
        let feedCell = app.tables.cells.firstMatch
        XCTAssertTrue(feedCell.waitForExistence(timeout: 20),
                     "Экран ленты не загрузился")
        print("Успешный переход на экран ленты")
    }
    
    // MARK: - Вспомогательные методы
    private func slowType(text: String, element: XCUIElement, delay: UInt32 = 150_000) {
        for char in text {
            element.typeText(String(char))
            usleep(delay) // Задержка между вводом символов
        }
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
       
        XCTAssertTrue(app.staticTexts["Владимир Ольшевский"].exists)
        XCTAssertTrue(app.staticTexts["@vovan098"].exists)
        
        app.buttons["Exit"].tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}

class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testFeed() throws {

        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()

        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 3)
        
        //        cellToLike.buttons["unactiveLike"].tap()
        //        cellToLike.buttons["activeLike"].tap()
        
        cellToLike.buttons.firstMatch.tap()

        sleep(2)
        cellToLike.buttons.firstMatch.tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1) 
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["Backward"]
        navBackButtonWhiteButton.tap()
    }
}
