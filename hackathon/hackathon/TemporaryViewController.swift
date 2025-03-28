import UIKit

class TemporaryViewController: UIViewController, LogoLoadingDelegate {
    
    private var messageLabel: UILabel!
    private var logoImageView: UIImageView!
    private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadLogo()
        
        // Redirect to LearningFocusViewController after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.navigateToLearningFocus()
        }
    }
    
    private func setupUI() {
        // Setup background
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.image = UIImage(named: "background")
        backgroundImageView.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImageView, at: 0)
        
        // Setup message label
        messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = "Hello, let's generate a path according to your interest!"
        messageLabel.textColor = .white
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.boldSystemFont(ofSize: 22)
        messageLabel.numberOfLines = 0
        view.addSubview(messageLabel)
        
        // Setup logo image view
        logoImageView = UIImageView()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        view.addSubview(logoImageView)
        
        // Setup activity indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            logoImageView.widthAnchor.constraint(equalToConstant: 150),
            logoImageView.heightAnchor.constraint(equalToConstant: 150),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 30)
        ])
    }
    
    private func loadLogo() {
        // Use LogoService to load the logo
        LogoService.shared.loadLogo(delegate: self)
    }
    
    private func navigateToLearningFocus() {
        let learningFocusVC = LearningFocusViewController()
        learningFocusVC.modalPresentationStyle = .fullScreen
        learningFocusVC.modalTransitionStyle = .crossDissolve
        present(learningFocusVC, animated: true)
    }

    
    func didLoadLogo(image: UIImage?, randomSentence: String?) {
        logoImageView.image = image
        activityIndicator.stopAnimating()
    }
    
    func didFailToLoadLogo(error: Error?) {
        logoImageView.image = LogoService.shared.getFallbackImage()
        logoImageView.tintColor = .white
        activityIndicator.stopAnimating()
    }
}
