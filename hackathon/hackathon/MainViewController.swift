import UIKit

class MainViewController: UIViewController, LogoLoadingDelegate {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    
    private var generatePathButton: UIButton!
    var userData: [String: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundImage()
        setupUI()
        loadLogo()
        if let data = userData {
            updateUI(with: data)
        }
    }
    
    private func setupUI() {
        navigationItem.hidesBackButton = true
        
        profileImageView.layer.cornerRadius = 75
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        
        // Create Generate Path button
        generatePathButton = UIButton(type: .system)
        generatePathButton.translatesAutoresizingMaskIntoConstraints = false
        generatePathButton.setTitle("Generate Path", for: .normal)
        generatePathButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        generatePathButton.backgroundColor = .systemBlue
        generatePathButton.setTitleColor(.white, for: .normal)
        generatePathButton.layer.cornerRadius = 10
        generatePathButton.addTarget(self, action: #selector(generatePathTapped), for: .touchUpInside)
        
        view.addSubview(generatePathButton)
        
        // Add constraints for the button
        NSLayoutConstraint.activate([
            generatePathButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            generatePathButton.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -20),
            generatePathButton.widthAnchor.constraint(equalToConstant: 200),
            generatePathButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func generatePathTapped() {
        let tempVC = TemporaryViewController()
        tempVC.modalPresentationStyle = .fullScreen
        tempVC.modalTransitionStyle = .crossDissolve
        present(tempVC, animated: true)
    }
    
    private func loadLogo() {
        // Use LogoService to load the logo
        LogoService.shared.loadLogo(delegate: self)
    }
    
    func didLoadLogo(image: UIImage?, randomSentence: String?) {
        logoImageView.image = image
    }
    
    func didFailToLoadLogo(error: Error?) {
        print("Error loading logo: \(error?.localizedDescription ?? "Unknown error")")
        // Use fallback image if needed
        logoImageView.image = LogoService.shared.getFallbackImage()
        logoImageView.tintColor = .white
    }
    
    private func updateUI(with data: [String: Any]) {
        welcomeLabel.text = "Welcome, \(data["name"] as? String ?? "")!"
        nameLabel.text = "Name: \(data["name"] as? String ?? "")"
        lastNameLabel.text = "Last Name: \(data["lastname"] as? String ?? "")"
        birthDateLabel.text = "Birth Date: \(data["birthdate"] as? String ?? "")"
        descriptionLabel.text = "Description: \(data["description"] as? String ?? "")"
        
        if let imageString = data["image"] as? String,
           let imageData = Data(base64Encoded: imageString),
           let image = UIImage(data: imageData) {
            profileImageView.image = image
        }
    }
    
    @objc private func logoutTapped() {
        navigationController?.popToRootViewController(animated: true)
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
        welcomeLabel.textColor = .white
        nameLabel.textColor = .white
        lastNameLabel.textColor = .white
        birthDateLabel.textColor = .white
        descriptionLabel.textColor = .white
        
        // Configurar los botones para que sean rojos
        logoutButton.tintColor = .red
        logoutButton.configuration?.baseBackgroundColor = .red
    }
}
