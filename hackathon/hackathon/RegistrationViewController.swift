import UIKit

class RegistrationViewController: UIViewController, LogoLoadingDelegate {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var birthDatePicker: UIDatePicker!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    private var selectedImage: UIImage?
    private let imagePicker = UIImagePickerController()
    private var birthDateLabel: UILabel!
    private var formContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Registration"
        setupBackgroundImage()
        setupUI()
        loadLogo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Ensure form elements are properly aligned after layout
        alignFormElements()
    }
    
    private func setupUI() {
        // Create a container view for the form
        setupFormContainer()
        setupPlaceholders()
        styleTextFields()
        
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.white.cgColor
        descriptionTextView.layer.cornerRadius = 10
        
        if descriptionTextView.text == "Description" {
            descriptionTextView.textColor = .white
            descriptionTextView.alpha = 0.7
        }
        
        // Setup delegates
        descriptionTextView.delegate = self
        imagePicker.delegate = self
        nameTextField.delegate = self
        lastNameTextField.delegate = self
        passwordTextField.delegate = self
        
        // Style buttons
        styleButtons()
        
        // Add targets
        addImageButton.addTarget(self, action: #selector(addImageTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        
        // Setup date picker after other UI elements
        setupDatePickerUI()
    }
    
    private func alignFormElements() {
        // Get the width of the form container or the view if container is not available
        let containerWidth = formContainerView?.bounds.width ?? view.bounds.width - 40
        let standardWidth = containerWidth - 40 // Leave some margin
        
        // Set standard width for all text fields
        nameTextField.frame.size.width = standardWidth
        lastNameTextField.frame.size.width = standardWidth
        passwordTextField.frame.size.width = standardWidth
        descriptionTextView.frame.size.width = standardWidth
        
        // Center the text fields horizontally
        let centerX = (formContainerView?.center.x ?? view.center.x)
        nameTextField.center.x = centerX
        lastNameTextField.center.x = centerX
        passwordTextField.center.x = centerX
        descriptionTextView.center.x = centerX
        birthDatePicker.center.x = centerX
        registerButton.center.x = centerX
        
        // Ensure the date picker has the same width as other fields
        birthDatePicker.frame.size.width = standardWidth
        
        // Adjust the birth date label position
        if let birthDateLabel = birthDateLabel {
            birthDateLabel.frame.origin.x = nameTextField.frame.origin.x
            birthDateLabel.frame.origin.y = birthDatePicker.frame.origin.y - 30
        }
    }
    
    private func setupFormContainer() {
        // Create a semi-transparent container for the form
        formContainerView = UIView()
        formContainerView.translatesAutoresizingMaskIntoConstraints = false
        formContainerView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        formContainerView.layer.cornerRadius = 15
        formContainerView.layer.borderWidth = 1
        formContainerView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        
        // Add padding around form elements
        view.insertSubview(formContainerView, at: 1)
        
        // Position the container to encompass all form elements
        if let firstField = nameTextField, let lastField = registerButton {
            NSLayoutConstraint.activate([
                formContainerView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
                formContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                formContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                formContainerView.bottomAnchor.constraint(equalTo: lastField.bottomAnchor, constant: 20)
            ])
        }
    }
    
    private func styleTextFields() {
        // Apply consistent styling to all text fields
        let textFields = [nameTextField, lastNameTextField, passwordTextField]
        
        for textField in textFields {
            textField?.layer.cornerRadius = 10
            textField?.layer.borderWidth = 1
            textField?.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
            textField?.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField!.frame.height))
            textField?.leftViewMode = .always
        }
        
        // Style the description text view
        descriptionTextView.layer.cornerRadius = 10
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    private func styleButtons() {
        // Style the register button
        registerButton.layer.cornerRadius = 10
        registerButton.layer.shadowColor = UIColor.black.cgColor
        registerButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        registerButton.layer.shadowOpacity = 0.5
        registerButton.layer.shadowRadius = 4
        
        // Style the add image button
        addImageButton.layer.cornerRadius = 10
        addImageButton.layer.shadowColor = UIColor.black.cgColor
        addImageButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        addImageButton.layer.shadowOpacity = 0.5
        addImageButton.layer.shadowRadius = 4
    }
    
    private func setupDatePickerUI() {
        // Create birth date label
        birthDateLabel = UILabel()
        birthDateLabel.translatesAutoresizingMaskIntoConstraints = false
        birthDateLabel.text = "Birth Date"
        birthDateLabel.textColor = .white
        birthDateLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        view.addSubview(birthDateLabel)
        
        // Style the date picker to match other form elements
        birthDatePicker.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
        birthDatePicker.layer.cornerRadius = 10
        birthDatePicker.layer.borderWidth = 1
        birthDatePicker.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        birthDatePicker.tintColor = .white
        birthDatePicker.setValue(UIColor.white, forKey: "textColor")
        
        // Position the label
        if let superview = birthDatePicker.superview {
            superview.addSubview(birthDateLabel)
            
            NSLayoutConstraint.activate([
                birthDateLabel.bottomAnchor.constraint(equalTo: birthDatePicker.topAnchor, constant: -8),
                birthDateLabel.leadingAnchor.constraint(equalTo: birthDatePicker.leadingAnchor)
            ])
        }
    }
    
    private func setupPlaceholders() {
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.7),
            .font: UIFont.systemFont(ofSize: 16)
        ]
        
        nameTextField.attributedPlaceholder = NSAttributedString(
            string: "Name", 
            attributes: placeholderAttributes
        )
        
        lastNameTextField.attributedPlaceholder = NSAttributedString(
            string: "Last Name", 
            attributes: placeholderAttributes
        )
        
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Password", 
            attributes: placeholderAttributes
        )
    }
    
    private func loadLogo() {
        LogoService.shared.loadLogo(delegate: self)
    }
    
    func didLoadLogo(image: UIImage?, randomSentence: String?) {
        logoImageView.image = image
    }
    
    func didFailToLoadLogo(error: Error?) {
        print("Error loading logo: \(error?.localizedDescription ?? "Unknown error")")
        logoImageView.image = LogoService.shared.getFallbackImage()
        logoImageView.tintColor = .white
    }
    
    @objc private func addImageTapped() {
        let alert = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
                self?.imagePicker.sourceType = .camera
                self?.present(self?.imagePicker ?? UIImagePickerController(), animated: true)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
            self?.imagePicker.sourceType = .photoLibrary
            self?.present(self?.imagePicker ?? UIImagePickerController(), animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func registerTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let lastName = lastNameTextField.text, !lastName.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let description = descriptionTextView.text, description != "Description", !description.isEmpty else {
            showAlert(message: "Please fill in all fields", isSuccess: false)
            return
        }
        
        // Show loading indicator
        let loadingAlert = UIAlertController(title: nil, message: "Registering...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        loadingAlert.view.addSubview(loadingIndicator)
        present(loadingAlert, animated: true)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let birthdate = dateFormatter.string(from: birthDatePicker.date)
        
        var imageString = ""
        if let image = selectedImage,
           let imageData = image.jpegData(compressionQuality: 0.5) {
            imageString = imageData.base64EncodedString()
        }
        
        // Create the request body as a dictionary first
        let requestBody: [String: Any] = [
            "user": [
                "name": name,
                "lastname": lastName,
                "birthdate": birthdate,
                "password": password,
                "description": description,
                "image": imageString
            ]
        ]
        
        // Log the request for debugging
        print("Sending registration request with data: \(requestBody)")
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            loadingAlert.dismiss(animated: true) {
                self.showAlert(message: "Error creating registration data", isSuccess: false)
            }
            return
        }
        
        guard let url = URL(string: "https://hackaton-rails-api.duckdns.org:3000/users") else {
            loadingAlert.dismiss(animated: true) {
                self.showAlert(message: "Invalid URL", isSuccess: false)
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Print request details for debugging
        print("Request URL: \(url.absoluteString)")
        print("Request headers: \(request.allHTTPHeaderFields ?? [:])")
        if let body = String(data: jsonData, encoding: .utf8) {
            print("Request body: \(body)")
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            // Always dismiss the loading indicator first
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    // Handle the response
                    if let error = error {
                        print("Network error: \(error.localizedDescription)")
                        self?.showAlert(message: "Network error: \(error.localizedDescription)", isSuccess: false)
                        return
                    }
                    
                    // Print response details for debugging
                    if let httpResponse = response as? HTTPURLResponse {
                        print("Response status code: \(httpResponse.statusCode)")
                        print("Response headers: \(httpResponse.allHeaderFields)")
                    }
                    
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("Response data: \(responseString)")
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                            if let data = data {
                                do {
                                    if let userData = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                                        print("Registration successful! User data: \(userData)")
                                        self?.navigateToMainScreen(with: userData)
                                    } else {
                                        print("Could not parse user data as dictionary")
                                        self?.showAlert(message: "Registration successful but error parsing user data", isSuccess: true)
                                        // Still navigate to main screen on successful registration
                                        self?.navigateToMainScreen(with: ["name": name, "lastname": lastName])
                                    }
                                } catch {
                                    print("JSON parsing error: \(error.localizedDescription)")
                                    self?.showAlert(message: "Registration successful but error parsing response: \(error.localizedDescription)", isSuccess: true)
                                    // Still navigate to main screen on successful registration
                                    self?.navigateToMainScreen(with: ["name": name, "lastname": lastName])
                                }
                            } else {
                                print("No data in response")
                                self?.showAlert(message: "Registration successful but no data returned", isSuccess: true)
                                // Still navigate to main screen on successful registration
                                self?.navigateToMainScreen(with: ["name": name, "lastname": lastName])
                            }
                        } else {
                            // Try to parse error message from response
                            if let data = data, let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                               let errorMessage = errorDict["error"] as? String {
                                print("Server error: \(errorMessage)")
                                self?.showAlert(message: "Registration failed: \(errorMessage)", isSuccess: false)
                            } else {
                                print("Registration failed with status code: \(httpResponse.statusCode)")
                                self?.showAlert(message: "Registration failed with status code: \(httpResponse.statusCode)", isSuccess: false)
                            }
                        }
                    } else {
                        print("Invalid response type")
                        self?.showAlert(message: "Invalid server response", isSuccess: false)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    private func navigateToMainScreen(with userData: [String: Any]) {
        if let mainVC = storyboard?.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController {
            mainVC.userData = userData
            navigationController?.pushViewController(mainVC, animated: true)
        }
    }
    
    private func showAlert(message: String, isSuccess: Bool) {
        let alert = UIAlertController(title: isSuccess ? "Success" : "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupBackgroundImage() {
        // Crear una imagen de fondo que cubra toda la pantalla
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.image = UIImage(named: "background")
        backgroundImageView.contentMode = .scaleToFill
        
        backgroundImageView.tag = 100
        self.view.insertSubview(backgroundImageView, at: 0)
        
        // Configurar el texto para que sea blanco
        nameTextField.textColor = .white
        lastNameTextField.textColor = .white
        passwordTextField.textColor = .white
        descriptionTextView.textColor = .white
        
        // Configurar el fondo de los campos de texto
        nameTextField.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
        lastNameTextField.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
        passwordTextField.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
        descriptionTextView.backgroundColor = UIColor(white: 0.3, alpha: 1.0)
        
        // Configurar los botones para que sean rojos
        addImageButton.tintColor = .red
        addImageButton.configuration?.baseBackgroundColor = .red
        registerButton.tintColor = .red
        registerButton.configuration?.baseBackgroundColor = .red
    }
}

extension RegistrationViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .white && textView.alpha == 0.7 {
            textView.text = ""
            textView.textColor = .white
            textView.alpha = 1.0
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description"
            textView.textColor = .white
            textView.alpha = 0.7
        }
    }
}

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension RegistrationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image
            addImageButton.setTitle("Image Selected ", for: .normal)
        }
        
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
