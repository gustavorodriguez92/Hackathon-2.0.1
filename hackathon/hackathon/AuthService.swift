import UIKit

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    // Método centralizado para cerrar sesión desde cualquier parte de la aplicación
    func logout(from viewController: UIViewController) {
        print("🔐 Cerrando sesión...")
        
        // Aquí podrías agregar lógica para limpiar datos de usuario, tokens, etc.
        // UserDefaults.standard.removeObject(forKey: "userToken")
        // UserDefaults.standard.synchronize()
        
        // Navegar a la pantalla inicial del storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Obtener el controlador inicial del storyboard
        if let initialVC = storyboard.instantiateInitialViewController() {
            initialVC.modalPresentationStyle = .fullScreen
            initialVC.modalTransitionStyle = .crossDissolve
            
            // Establecer el controlador inicial como root para asegurar que se cierra toda la pila de navegación
            UIApplication.shared.windows.first?.rootViewController = initialVC
            UIApplication.shared.windows.first?.makeKeyAndVisible()
            
            print("✅ Sesión cerrada correctamente")
        } else {
            print("❌ Error al cerrar sesión: No se pudo instanciar el controlador inicial")
        }
    }
}
