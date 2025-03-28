import UIKit

class LearningFocusViewController: UIViewController {
    
    private var titleLabel: UILabel!
    private var focusOptionsStackView: UIStackView!
    private var backButton: UIButton!
    private var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // Setup background
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.image = UIImage(named: "background")
        backgroundImageView.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImageView, at: 0)
        
        // Setup title label
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Pick A Learning Focus"
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        view.addSubview(titleLabel)
        
        // Setup focus options stack view
        focusOptionsStackView = UIStackView()
        focusOptionsStackView.translatesAutoresizingMaskIntoConstraints = false
        focusOptionsStackView.axis = .vertical
        focusOptionsStackView.spacing = 20
        focusOptionsStackView.distribution = .fillEqually
        view.addSubview(focusOptionsStackView)
        
        // Add focus options
        let focusOptions = ["Web Development", "Mobile Development", "Data Science", "Machine Learning", "UI/UX Design"]
        for option in focusOptions {
            let optionButton = createFocusOptionButton(title: option)
            focusOptionsStackView.addArrangedSubview(optionButton)
        }
        
        // Setup back button
        backButton = UIButton(type: .system)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setTitle("Back to Main", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        backButton.setTitleColor(.white, for: .normal)
        backButton.backgroundColor = .systemRed
        backButton.layer.cornerRadius = 10
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        view.addSubview(backButton)
        
        // Setup logout button
        logoutButton = UIButton(type: .system)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.setTitle("Log Out", for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.backgroundColor = .systemRed
        logoutButton.layer.cornerRadius = 10
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        view.addSubview(logoutButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            focusOptionsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            focusOptionsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            focusOptionsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            backButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 10),
            backButton.widthAnchor.constraint(equalToConstant: 150),
            backButton.heightAnchor.constraint(equalToConstant: 50),
            
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            logoutButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -10),
            logoutButton.widthAnchor.constraint(equalToConstant: 150),
            logoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func createFocusOptionButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(self, action: #selector(focusOptionTapped(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func focusOptionTapped(_ sender: UIButton) {
        guard let focusOption = sender.titleLabel?.text else { return }
        
        // Create and navigate to the CourseRecommendationsViewController
        let recommendationsVC = CourseRecommendationsViewController()
        recommendationsVC.selectedFocus = focusOption
        
        // Check if we're in a navigation controller
        if let navigationController = self.navigationController {
            // Use push navigation if we have a navigation controller
            navigationController.pushViewController(recommendationsVC, animated: true)
        } else {
            // Present modally if we don't have a navigation controller
            recommendationsVC.modalPresentationStyle = .fullScreen
            recommendationsVC.modalTransitionStyle = .crossDissolve
            present(recommendationsVC, animated: true)
        }
    }
    
    @objc private func backButtonTapped() {
        // Navegar directamente a MainViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainVC = storyboard.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController {
            // Configurar la presentación a pantalla completa con transición suave
            mainVC.modalPresentationStyle = .fullScreen
            mainVC.modalTransitionStyle = .crossDissolve
            
            // Presentar MainViewController y reemplazar la vista actual
            if let navigationController = self.navigationController {
                // Si estamos en un navigation controller, volver a la raíz y luego presentar
                navigationController.popToRootViewController(animated: false)
                navigationController.viewControllers.first?.present(mainVC, animated: true)
            } else {
                // Si fuimos presentados modalmente, descartar esta vista y presentar MainViewController
                self.dismiss(animated: false) { [weak self] in
                    // Obtener el controlador que presentó esta vista
                    if let presentingVC = self?.presentingViewController {
                        presentingVC.present(mainVC, animated: true)
                    } else {
                        // Fallback: establecer MainViewController como root
                        UIApplication.shared.windows.first?.rootViewController = mainVC
                        UIApplication.shared.windows.first?.makeKeyAndVisible()
                    }
                }
            }
        } else {
            // Fallback: simplemente descartar esta vista si no se puede instanciar MainViewController
            dismiss(animated: true)
        }
    }
    
    @objc private func logoutButtonTapped() {
        // Usar el servicio centralizado para cerrar sesión
        AuthService.shared.logout(from: self)
    }
}
