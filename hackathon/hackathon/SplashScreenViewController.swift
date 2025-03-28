import UIKit


class SplashScreenViewController: UIViewController, LogoLoadingDelegate {
    
    private var logoImageView: UIImageView!
    private var activityIndicator: UIActivityIndicatorView!
    private var randomSentenceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadLogo()
    }
    
    private func setupUI() {
        // Configurar la imagen de fondo
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.image = UIImage(named: "background")
        backgroundImageView.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImageView, at: 0)
        
        // Configurar el logo
        logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        logoImageView.center = view.center
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
    
    func loadLogo() {
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
        
        // Navegar a la pantalla principal después de un breve retraso
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.navigateToMainScreen()
        }
    }
    
    func didFailToLoadLogo(error: Error?) {
        fallbackToLocalLogo()
    }
    
    private func fallbackToLocalLogo() {
        DispatchQueue.main.async{
            // Si no se puede cargar el logo desde la API, usar uno local
            self.logoImageView.image = LogoService.shared.getFallbackImage()
            self.logoImageView.tintColor = .white
            self.randomSentenceLabel.text = "Welcome to our app!"
            self.randomSentenceLabel.alpha = 1.0
            self.activityIndicator.stopAnimating()
        }
        
        // Navegar a la pantalla principal después de un breve retraso
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.navigateToMainScreen()
        }
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
