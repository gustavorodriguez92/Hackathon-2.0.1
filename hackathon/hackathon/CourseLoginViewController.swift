import UIKit
import WebKit

class CourseLoginViewController: UIViewController {
    
    // MARK: - Properties
    private var webView: WKWebView!
    private var loadingIndicator: UIActivityIndicatorView!
    private var backButton: UIButton!
    private var logoutButton: UIButton!
    private var logoImageView: UIImageView!
    private var titleLabel: UILabel!
    
    // Course and platform information
    var platform: String = ""
    var courseTitle: String = ""
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadLoginPage()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupBackgroundImage()
        setupLogo()
        setupTitleLabel()
        setupWebView()
        setupLoadingIndicator()
        setupBackButton()
        setupLogoutButton()
    }
    
    private func setupBackgroundImage() {
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.image = UIImage(named: "background")
        backgroundImageView.contentMode = .scaleToFill
        backgroundImageView.tag = 100
        self.view.insertSubview(backgroundImageView, at: 0)
    }
    
    private func setupLogo() {
        logoImageView = UIImageView()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 150),
            logoImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        // Use a placeholder logo until the real one is loaded
        logoImageView.image = UIImage(systemName: "book.fill")
        logoImageView.tintColor = .red
        
        // Load the actual logo
        LogoService.shared.loadLogo { [weak self] image, randomSentence, error in
            DispatchQueue.main.async {
                self?.logoImageView.image = image
            }
        }
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Login to \(platform)"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupWebView() {
        // Create WKWebView configuration
        let configuration = WKWebViewConfiguration()
        
        // Create the web view
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = .white
        webView.layer.cornerRadius = 10
        webView.clipsToBounds = true
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80)
        ])
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.color = .white
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: webView.centerYAnchor)
        ])
    }
    
    private func setupBackButton() {
        backButton = UIButton(type: .system)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setTitle("Back", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        backButton.setTitleColor(.white, for: .normal)
        backButton.backgroundColor = .systemRed
        backButton.layer.cornerRadius = 10
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            backButton.widthAnchor.constraint(equalToConstant: 120),
            backButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupLogoutButton() {
        logoutButton = UIButton(type: .system)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.setTitle("Log Out", for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.backgroundColor = .systemBlue
        logoutButton.layer.cornerRadius = 10
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            logoutButton.widthAnchor.constraint(equalToConstant: 120),
            logoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func logoutButtonTapped() {
        // Usar el servicio centralizado para cerrar sesión
        AuthService.shared.logout(from: self)
    }
    
    // MARK: - Web Loading
    private func loadLoginPage() {
        loadingIndicator.startAnimating()
        
        // Determine the login URL based on the platform
        var urlString = ""
        switch platform.lowercased() {
        case "myacademy":
            urlString = "https://myacademy.com/login"
        case "linkedin learning":
            urlString = "https://www.linkedin.com/learning/login"
        case "pluralsight":
            urlString = "https://app.pluralsight.com/id"
        default:
            urlString = "https://www.google.com/search?q=\(platform)+\(courseTitle)+course+login"
        }
        
        // URL encode the course title if needed
        if let encodedCourseTitle = courseTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            urlString = urlString.replacingOccurrences(of: courseTitle, with: encodedCourseTitle)
        }
        
        // Load the URL
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
            print("🌐 Loading login page: \(urlString)")
        } else {
            showAlert(title: "Error", message: "Invalid URL for \(platform)")
            loadingIndicator.stopAnimating()
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}

// MARK: - WKNavigationDelegate
extension CourseLoginViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
        
        // Check if we've successfully logged in
        if let url = webView.url?.absoluteString {
            print("📄 Loaded page: \(url)")
            
            // You could add logic here to detect successful login
            // For example, check if the URL contains certain patterns
            
            // For demonstration purposes, we'll just update the title
            if !url.contains("login") && !url.contains("id") {
                titleLabel.text = "Enrolled in \(courseTitle)"
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
        print("❌ Navigation failed: \(error.localizedDescription)")
        showAlert(title: "Error", message: "Failed to load page: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
        print("❌ Provisional navigation failed: \(error.localizedDescription)")
        showAlert(title: "Error", message: "Failed to load page: \(error.localizedDescription)")
    }
}
