import UIKit

class LaunchScreenViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadLogo()
    }
    
    private func setupUI() {
        // Configurar la imagen de fondo
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.image = UIImage(named: "background")
        backgroundImageView.contentMode = .scaleToFill
        view.insertSubview(backgroundImageView, at: 0)
        
        // Iniciar el indicador de actividad
        if let activityIndicator = view.subviews.compactMap({ $0 as? UIActivityIndicatorView }).first {
            activityIndicator.startAnimating()
        }
    }
    
    private func loadLogo() {
        guard let url = URL(string: "https://hackaton-rails-api.duckdns.org:3000/assets?logo_type=light") else { 
            print("Error: Invalid URL")
            fallbackToLocalLogo()
            return 
        }
        
        print("Loading logo from URL: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error loading logo: \(error.localizedDescription)")
                self?.fallbackToLocalLogo()
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    print("Error: Unexpected status code \(httpResponse.statusCode)")
                    self?.fallbackToLocalLogo()
                    return
                }
            }
            
            guard let data = data else { 
                print("Error: No data received")
                self?.fallbackToLocalLogo()
                return 
            }
            
            print("Data received: \(data.count) bytes")
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    print("Image loaded successfully with size: \(image.size.width) x \(image.size.height)")
                    self?.logoImageView.image = image
                } else {
                    print("Error: Could not create image from data. Data might not be a valid image format.")
                    self?.fallbackToLocalLogo()
                }
            }
        }.resume()
    }
    
    private func fallbackToLocalLogo() {
        DispatchQueue.main.async {
            // Si no se puede cargar el logo desde la API, usar uno local
            self.logoImageView.image = UIImage(systemName: "star.fill")
            self.logoImageView.tintColor = .white
        }
    }
}
