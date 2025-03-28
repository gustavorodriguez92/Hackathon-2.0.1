import UIKit

class ViewController: UIViewController, LogoLoadingDelegate {
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundImage()
        loadLogo()
    }
    
    private func loadLogo() {
        LogoService.shared.loadLogo(delegate: self)
    }
    
    // MARK: - LogoLoadingDelegate
    
    func didLoadLogo(image: UIImage?, randomSentence: String?) {
        logoImageView.image = image
    }
    
    func didFailToLoadLogo(error: Error?) {
        print("Error loading logo: \(error?.localizedDescription ?? "Unknown error")")
        // Podríamos implementar un fallback aquí si es necesario
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
        
        // Configurar los botones para que sean rojos
        for subview in view.subviews {
            if let button = subview as? UIButton {
                button.tintColor = .red
                button.configuration?.baseBackgroundColor = .red
            }
        }
    }
}
