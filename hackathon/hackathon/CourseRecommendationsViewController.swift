import UIKit

class CourseRecommendationsViewController: UIViewController {
    
    // MARK: - Properties
    private var titleLabel: UILabel!
    private var loadingIndicator: UIActivityIndicatorView!
    private var tableView: UITableView!
    private var backButton: UIButton!
    private var logoutButton: UIButton!
    private var logoImageView: UIImageView!
    
    // Data
    var selectedFocus: String = ""
    private var recommendations: [CourseRecommendation] = []
    
    // OpenAI API Key - Obtenida desde el archivo de configuración
    private var openAIAPIKey: String {
        return Config.openAIAPIKey
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchRecommendations()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupBackgroundImage()
        setupLogo()
        setupTitleLabel()
        setupLoadingIndicator()
        setupTableView()
        setupBackButton()
        setupLogoutButton()
    }
    
    private func setupBackgroundImage() {
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.image = UIImage(named: "background")
        backgroundImageView.contentMode = .scaleToFill
        backgroundImageView.tag = 100
        self.view.insertSubview(backgroundImageView, at: 0)
    }
    
    private func setupLogo() {
        logoImageView = UIImageView()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 150),
            logoImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        // Use a placeholder logo until the real one is loaded
        logoImageView.image = UIImage(systemName: "book.fill")
        logoImageView.tintColor = .red
        
        // Load the actual logo
        LogoService.shared.loadLogo { [weak self] image, randomSentence, error in
            DispatchQueue.main.async {
                self?.logoImageView.image = image
            }
        }
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Course Recommendations for \(selectedFocus)"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.color = .white
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        tableView.layer.cornerRadius = 10
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CourseRecommendationCell.self, forCellReuseIdentifier: "CourseCell")
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .lightGray
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.isHidden = true
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80)
        ])
    }
    
    private func setupBackButton() {
        backButton = UIButton(type: .system)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setTitle("Back", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        backButton.setTitleColor(.white, for: .normal)
        backButton.backgroundColor = .systemRed
        backButton.layer.cornerRadius = 10
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            backButton.widthAnchor.constraint(equalToConstant: 120),
            backButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupLogoutButton() {
        logoutButton = UIButton(type: .system)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.setTitle("Log Out", for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.backgroundColor = .systemBlue
        logoutButton.layer.cornerRadius = 10
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            logoutButton.widthAnchor.constraint(equalToConstant: 120),
            logoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func logoutButtonTapped() {
        // Usar el servicio centralizado para cerrar sesión
        AuthService.shared.logout(from: self)
    }
    
    // MARK: - Data Fetching
    private func fetchRecommendations() {
        loadingIndicator.startAnimating()
        tableView.isHidden = true
        
        print("🔍 Starting to fetch course recommendations for focus: \(selectedFocus)")
        
        // Skip the API key prompt since we have it hardcoded now
        fetchRecommendationsWithOpenAI(apiKey: openAIAPIKey)
    }
    
    private func fetchRecommendationsWithOpenAI(apiKey: String) {
        print("🔑 Using API key: \(String(apiKey.prefix(5)))...") // Only log the first 5 chars for security
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("❌ Error: Invalid API URL")
            showAlert(title: "Error", message: "Invalid API URL")
            loadingIndicator.stopAnimating()
            return
        }
        
        print("🌐 Preparing request to URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let prompt = """
        I need recommendations for courses from MyAcademy, LinkedIn Learning, and Pluralsight for someone interested in \(selectedFocus).
        
        For each platform, provide 3 course recommendations with the following information:
        1. Course title
        2. Instructor name
        3. Brief description (1-2 sentences)
        4. Difficulty level (Beginner, Intermediate, Advanced)
        5. Estimated duration
        
        Format your response as a JSON array with this structure:
        [
          {
            "platform": "MyAcademy",
            "courses": [
              {
                "title": "Course Title",
                "instructor": "Instructor Name",
                "description": "Brief description",
                "level": "Difficulty Level",
                "duration": "Duration"
              },
              ...
            ]
          },
          ...
        ]
        
        Only include the JSON in your response, no other text.
        """
        
        print("📝 Prompt prepared for OpenAI: \n\(prompt)")
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant that provides course recommendations in JSON format."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7
        ]
        
        do {
            let httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = httpBody
            print("📤 Request body prepared: \(httpBody.count) bytes")
            
            print("🚀 Sending request to OpenAI...")
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    print("📥 Received response from OpenAI")
                    
                    if let error = error {
                        print("❌ Network error: \(error.localizedDescription)")
                        self.showAlert(title: "Error", message: "Network error: \(error.localizedDescription)")
                        self.loadingIndicator.stopAnimating()
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        print("🔢 HTTP Status Code: \(httpResponse.statusCode)")
                        print("📋 Response Headers: \(httpResponse.allHeaderFields)")
                    }
                    
                    guard let data = data else {
                        print("❌ No data received from OpenAI")
                        self.showAlert(title: "Error", message: "No data received")
                        self.loadingIndicator.stopAnimating()
                        return
                    }
                    
                    print("📦 Received \(data.count) bytes of data")
                    
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("📄 Response content: \(responseString)")
                    }
                    
                    do {
                        // Parse the OpenAI response
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            print("🔍 Successfully parsed JSON response")
                            
                            // Log the entire JSON for debugging
                            print("📊 Full JSON response: \(json)")
                            
                            if let choices = json["choices"] as? [[String: Any]] {
                                print("✅ Found \(choices.count) choices in response")
                                
                                if let firstChoice = choices.first {
                                    print("🔍 Examining first choice: \(firstChoice)")
                                    
                                    if let message = firstChoice["message"] as? [String: Any] {
                                        print("✉️ Found message in choice")
                                        
                                        if let content = message["content"] as? String {
                                            print("📝 Content extracted: \(content.prefix(100))...")
                                            
                                            // Extract the JSON from the content
                                            if let jsonStartIndex = content.firstIndex(of: "["),
                                               let jsonEndIndex = content.lastIndex(of: "]") {
                                                let jsonContent = String(content[jsonStartIndex...jsonEndIndex])
                                                print("🔍 JSON content extracted: \(jsonContent.prefix(100))...")
                                                
                                                if let jsonData = jsonContent.data(using: .utf8) {
                                                    do {
                                                        let platformRecommendations = try JSONDecoder().decode([PlatformRecommendation].self, from: jsonData)
                                                        print("✅ Successfully decoded \(platformRecommendations.count) platform recommendations")
                                                        
                                                        // Flatten the recommendations for the table view
                                                        var allRecommendations: [CourseRecommendation] = []
                                                        
                                                        for platform in platformRecommendations {
                                                            print("📚 Platform: \(platform.platform) with \(platform.courses.count) courses")
                                                            
                                                            for course in platform.courses {
                                                                let recommendation = CourseRecommendation(
                                                                    platform: platform.platform,
                                                                    title: course.title,
                                                                    instructor: course.instructor,
                                                                    description: course.description,
                                                                    level: course.level,
                                                                    duration: course.duration
                                                                )
                                                                allRecommendations.append(recommendation)
                                                            }
                                                        }
                                                        
                                                        print("✅ Created \(allRecommendations.count) flattened course recommendations")
                                                        self.recommendations = allRecommendations
                                                        self.tableView.isHidden = false
                                                        self.tableView.reloadData()
                                                        self.loadingIndicator.stopAnimating()
                                                    } catch {
                                                        print("❌ JSON decoding error: \(error.localizedDescription)")
                                                        print("❌ JSON data that failed to decode: \(String(data: jsonData, encoding: .utf8) ?? "nil")")
                                                        self.showAlert(title: "Error", message: "Failed to decode JSON: \(error.localizedDescription)")
                                                        self.loadingIndicator.stopAnimating()
                                                    }
                                                } else {
                                                    print("❌ Failed to convert JSON content to data")
                                                    self.showAlert(title: "Error", message: "Failed to parse JSON content")
                                                    self.loadingIndicator.stopAnimating()
                                                }
                                            } else {
                                                print("❌ Could not find JSON brackets in content")
                                                print("❌ Content without JSON: \(content)")
                                                self.showAlert(title: "Error", message: "Invalid JSON format in response")
                                                self.loadingIndicator.stopAnimating()
                                            }
                                        } else {
                                            print("❌ No content found in message")
                                            self.showAlert(title: "Error", message: "No content in response message")
                                            self.loadingIndicator.stopAnimating()
                                        }
                                    } else {
                                        print("❌ No message found in choice")
                                        self.showAlert(title: "Error", message: "No message in response choice")
                                        self.loadingIndicator.stopAnimating()
                                    }
                                } else {
                                    print("❌ No choices found in response")
                                    self.showAlert(title: "Error", message: "No choices in response")
                                    self.loadingIndicator.stopAnimating()
                                }
                            } else {
                                print("❌ No choices array found in JSON")
                                self.showAlert(title: "Error", message: "Invalid response format: no choices")
                                self.loadingIndicator.stopAnimating()
                            }
                        } else {
                            print("❌ Failed to parse response as JSON")
                            self.showAlert(title: "Error", message: "Invalid response format")
                            self.loadingIndicator.stopAnimating()
                        }
                    } catch {
                        print("❌ JSON parsing error: \(error.localizedDescription)")
                        self.showAlert(title: "Error", message: "Failed to parse response: \(error.localizedDescription)")
                        self.loadingIndicator.stopAnimating()
                    }
                }
            }
            
            task.resume()
            print("📡 Request sent to OpenAI, waiting for response...")
            
        } catch {
            print("❌ Error creating request body: \(error.localizedDescription)")
            showAlert(title: "Error", message: "Failed to create request body: \(error.localizedDescription)")
            loadingIndicator.stopAnimating()
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CourseRecommendationsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recommendations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as! CourseRecommendationCell
        let recommendation = recommendations[indexPath.row]
        cell.configure(with: recommendation)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CourseRecommendationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Get the selected course recommendation
        let recommendation = recommendations[indexPath.row]
        
        // Create and configure the login view controller
        let loginVC = CourseLoginViewController()
        loginVC.platform = recommendation.platform
        loginVC.courseTitle = recommendation.title
        
        // Present the login view controller
        if let navigationController = self.navigationController {
            navigationController.pushViewController(loginVC, animated: true)
        } else {
            loginVC.modalPresentationStyle = .fullScreen
            loginVC.modalTransitionStyle = .crossDissolve
            present(loginVC, animated: true)
        }
    }
}

// MARK: - Models
struct PlatformRecommendation: Codable {
    let platform: String
    let courses: [Course]
}

struct Course: Codable {
    let title: String
    let instructor: String
    let description: String
    let level: String
    let duration: String
}

struct CourseRecommendation {
    let platform: String
    let title: String
    let instructor: String
    let description: String
    let level: String
    let duration: String
}

// MARK: - Custom Cell
class CourseRecommendationCell: UITableViewCell {
    private let platformLabel = UILabel()
    private let titleLabel = UILabel()
    private let instructorLabel = UILabel()
    private let levelLabel = UILabel()
    private let durationLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        // Platform label
        platformLabel.font = UIFont.boldSystemFont(ofSize: 14)
        platformLabel.textColor = .red
        platformLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(platformLabel)
        
        // Title label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Instructor label
        instructorLabel.font = UIFont.systemFont(ofSize: 14)
        instructorLabel.textColor = .lightGray
        instructorLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(instructorLabel)
        
        // Level label
        levelLabel.font = UIFont.systemFont(ofSize: 14)
        levelLabel.textColor = .white
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(levelLabel)
        
        // Duration label
        durationLabel.font = UIFont.systemFont(ofSize: 14)
        durationLabel.textColor = .white
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(durationLabel)
        
        NSLayoutConstraint.activate([
            platformLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            platformLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            platformLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            titleLabel.topAnchor.constraint(equalTo: platformLabel.bottomAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            instructorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            instructorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            instructorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            levelLabel.topAnchor.constraint(equalTo: instructorLabel.bottomAnchor, constant: 5),
            levelLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            levelLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.centerXAnchor, constant: -10),
            
            durationLabel.topAnchor.constraint(equalTo: instructorLabel.bottomAnchor, constant: 5),
            durationLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.centerXAnchor, constant: 10),
            durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            durationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with recommendation: CourseRecommendation) {
        platformLabel.text = recommendation.platform
        titleLabel.text = recommendation.title
        instructorLabel.text = "By \(recommendation.instructor)"
        levelLabel.text = "Level: \(recommendation.level)"
        durationLabel.text = "Duration: \(recommendation.duration)"
    }
}
