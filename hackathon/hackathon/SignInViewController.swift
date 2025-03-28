import UIKit

class SignInViewController: UIViewController, LogoLoadingDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    private var logoImageView: UIImageView!
    private var randomSentenceLabel: UILabel!
    private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign In"
        setupBackgroundImage()
        setupUI()
        loadLogo()
    }
    
    private func setupUI() {
        nameTextField.delegate = self
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        
        // Set white placeholder for better visibility
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.7),
            .font: UIFont.systemFont(ofSize: 16)
        ]
        
        nameTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter your name", 
            attributes: placeholderAttributes
        )
        
        // Configurar el logo
        logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        logoImageView.center = CGPoint(x: view.center.x, y: view.center.y - 100)
        logoImageView.contentMode = .scaleAspectFit
        view.addSubview(logoImageView)
        
        // Configurar el label para la frase aleatoria
        randomSentenceLabel = UILabel(frame: CGRect(x: 20, y: 0, width: view.bounds.width - 40, height: 60))
        randomSentenceLabel.center = CGPoint(x: view.center.x, y: view.center.y + 150)
        randomSentenceLabel.textAlignment = .center
        randomSentenceLabel.numberOfLines = 0
        randomSentenceLabel.textColor = .white
        randomSentenceLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        randomSentenceLabel.alpha = 0
        view.addSubview(randomSentenceLabel)
        
        // Añadir un indicador de actividad
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y + 120)
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    @objc private func continueButtonTapped() {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            showAlert(message: "Please enter your name")
            return
        }
        
        checkUser(name: name)
    }
    
    private func checkUser(name: String) {
        guard let url = URL(string: "https://hackaton-rails-api.duckdns.org:3000/users/?name=\(name)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(message: "Error: \(error.localizedDescription)")
                }
                return
            }
            
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        // User exists, get user data and navigate to main screen
                        if let data = data,
                           let userData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            self?.navigateToMainScreen(with: userData)
                        }
                    } else {
                        // User doesn't exist, navigate to registration
                        self?.navigateToRegistration()
                    }
                }
            }
        }.resume()
    }
    
    private func navigateToMainScreen(with userData: [String: Any]) {
        if let mainVC = storyboard?.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController {
            mainVC.userData = userData
            navigationController?.pushViewController(mainVC, animated: true)
        }
    }
    
    private func navigateToRegistration() {
        if let registrationVC = storyboard?.instantiateViewController(withIdentifier: "RegistrationViewController") as? RegistrationViewController {
            navigationController?.pushViewController(registrationVC, animated: true)
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupBackgroundImage() {
        // Crear una imagen de fondo que cubra toda la pantalla
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.image = UIImage(named: "background")
        backgroundImageView.contentMode = .scaleToFill
        
        // Asegurarse de que la imagen esté detrás de todos los otros elementos
        backgroundImageView.tag = 100
        
        // Agregar la imagen a la vista
        self.view.insertSubview(backgroundImageView, at: 0)
        
        // Configurar el texto para que sea blanco
        nameTextField.textColor = .white
        nameTextField.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
        
        // Configurar los botones para que sean rojos
        continueButton.tintColor = .red
        continueButton.configuration?.baseBackgroundColor = .red
    }
    
    private func loadLogo() {
        // Usar el servicio de logo para cargar el logo
        LogoService.shared.loadLogo(delegate: self)
    }
    
    func didLoadLogo(image: UIImage?, randomSentence: String?) {
        logoImageView.image = image
        randomSentenceLabel.text = randomSentence
        
        // Animar la aparición del texto
        UIView.animate(withDuration: 0.5) {
            self.randomSentenceLabel.alpha = 1.0
        }
        
        activityIndicator.stopAnimating()
    }
    
    func didFailToLoadLogo(error: Error?) {
        fallbackToLocalLogo()
    }
    
    private func fallbackToLocalLogo() {
        // Si no se puede cargar el logo desde la API, usar uno local
        logoImageView.image = LogoService.shared.getFallbackImage()
        logoImageView.tintColor = .white
        randomSentenceLabel.text = "Welcome to our app!"
        randomSentenceLabel.alpha = 1.0
        activityIndicator.stopAnimating()
    }
    
    private func navigateToMainScreen() {
        // Cargar el storyboard principal
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Obtener el view controller inicial
        if let initialViewController = storyboard.instantiateInitialViewController() {
            // Configurar la transición
            initialViewController.modalPresentationStyle = .fullScreen
            initialViewController.modalTransitionStyle = .crossDissolve
            
            // Presentar el view controller
            self.present(initialViewController, animated: true, completion: nil)
        }
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
