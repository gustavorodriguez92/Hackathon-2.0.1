import UIKit

// Completion handler typealias for logo loading
typealias LogoCompletionHandler = (UIImage?, String?, Error?) -> Void

// Protocol for logo loading delegate to handle UI updates
protocol LogoLoadingDelegate: AnyObject {
    func didLoadLogo(image: UIImage?, randomSentence: String?)
    func didFailToLoadLogo(error: Error?)
}

class LogoService {
    // Singleton instance
    static let shared = LogoService()
    
    // API URL for logo
    private let logoUrl = "https://hackaton-rails-api.duckdns.org:3000/assets?logo_type=light"
    
    // Private initializer for singleton
    private init() {}
    
    // Load logo with completion handler
    func loadLogo(completion: @escaping LogoCompletionHandler) {
        guard let url = URL(string: logoUrl) else {
            let error = NSError(domain: "com.hackathon.error", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            completion(nil, nil, error)
            return
        }
        
        print("Loading logo from URL: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error loading logo: \(error.localizedDescription)")
                completion(nil, nil, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                print("HTTP Response Headers: \(httpResponse.allHeaderFields)")
                
                if httpResponse.statusCode != 200 {
                    let statusError = NSError(domain: "com.hackathon.error", code: httpResponse.statusCode, 
                                             userInfo: [NSLocalizedDescriptionKey: "Unexpected status code \(httpResponse.statusCode)"])
                    completion(nil, nil, statusError)
                    return
                }
            }
            
            guard let data = data else {
                let dataError = NSError(domain: "com.hackathon.error", code: 1002, 
                                       userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(nil, nil, dataError)
                return
            }
            
            print("Data received: \(data.count) bytes")
            
            do {
                let decoder = JSONDecoder()
                let logoResponse = try decoder.decode(LogoResponse.self, from: data)
                
                if let image = self.decodeBase64ToImage(logoResponse.image) {
                    completion(image, logoResponse.random_sentence, nil)
                } else {
                    let imageError = NSError(domain: "com.hackathon.error", code: 1003, 
                                           userInfo: [NSLocalizedDescriptionKey: "Could not create image from base64 data"])
                    completion(nil, nil, imageError)
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                
                // Fallback: Try to load the image directly if JSON parsing fails
                if let image = UIImage(data: data) {
                    print("Fallback: Image loaded directly from data")
                    completion(image, nil, nil)
                } else {
                    completion(nil, nil, error)
                }
            }
        }.resume()
    }
    
    // Load logo with delegate
    func loadLogo(delegate: LogoLoadingDelegate) {
        loadLogo { image, randomSentence, error in
            DispatchQueue.main.async {
                if let image = image {
                    delegate.didLoadLogo(image: image, randomSentence: randomSentence)
                } else {
                    delegate.didFailToLoadLogo(error: error)
                }
            }
        }
    }
    
    // Helper method to decode base64 string to UIImage
    func decodeBase64ToImage(_ base64String: String) -> UIImage? {
        let cleanBase64String = base64String.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let imageData = Data(base64Encoded: cleanBase64String, options: .ignoreUnknownCharacters) else {
            print("Error: Invalid Base64 string")
            return nil
        }
        return UIImage(data: imageData)
    }
    
    // Get a fallback local image
    func getFallbackImage() -> UIImage? {
        return UIImage(systemName: "star.fill")
    }
}
