import UIKit

struct LogoResponse: Decodable {
    let image: String
    let random_sentence: String
    
    enum CodingKeys: String, CodingKey {
        case image
        case random_sentence
    }
    
    // Computed property to convert base64 string to UIImage
    var uiImage: UIImage? {
        guard let imageData = Data(base64Encoded: image) else {
            return nil
        }
        return UIImage(data: imageData)
    }
}
