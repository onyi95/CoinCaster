CoinCaster: A Cryptocurrency Price Alert App

Introduction

CoinCaster is a project born from my interest in software development and a personal challenge to enhance my skills in iOS and backend technologies. By developing this cryptocurrency price alert app, I aimed to dive deeper into Swift, Flask, and the mechanics of real-time data processing and notifications. It’s a demonstration of my ability to create a functional, user-oriented application, reflecting my journey in mastering these technologies.
This project is a comprehensive iOS application designed to notify users when Bitcoin reaches a specified target price. Built with Swift and leveraging the iOS SDK, the app integrates a Flask backend to manage user registrations, login sessions, and target price alerts. The application showcases robust Object-Oriented Programming (OOP) practices, API design, multithreading for asynchronous tasks, and effective mobile memory management.

<p float="left">
  <img src="/Screenshots/WelcomeScreen.png" width="100" />
  <img src="/Screenshots/CurrencySelection.png" width="100" />
  <img src="/Screenshots/SetPriceTarget.png" width="100" />
 <img src="/Screenshots/Incoming Price Alert.png" width="100" />
</p>

Features
* User Authentication: Supports user registration and login, ensuring secure access to the app.
* Target Price Alerts: Allows users to set a target price for Bitcoin. When the current price crosses this target, the user receives a push notification.
* APNs Integration: Utilises Apple Push Notification service (APNs) for delivering real-time price alerts.
* Persistent User Sessions: Implements persistent sessions using UserDefaults and Keychain, enhancing the user experience by retaining session state across app restarts.
* Dynamic Price Updates: Integrates with a cryptocurrency API to fetch live Bitcoin prices, enabling users to make informed decisions when setting target alerts.

Technical Details
* Language: Swift for iOS app development, Python (Flask) for the backend service.
* Architecture: MVC (Model-View-Controller) for organised and maintainable codebase.
* Networking: URLSession for handling API requests to both the cryptocurrency API and the custom Flask backend.
* Data Persistence: UserDefaults for simple data storage, Keychain for secure storage of sensitive information like user tokens.
* Push Notifications: Configuration and handling of APNs for sending and receiving notifications.
* Concurrency: Utilisation of asynchronous programming patterns to maintain UI responsiveness and handle network requests.
* API Design: Flask RESTful API design for managing user data, authentication, and target price alerts and is hosted on Heroku.

Setup and Configuration
Prerequisites:
* Xcode
* Swift
* Python 3 and Flask for the backend
* An APNs certificate for push notifications

Running the Project
* Backend Setup:
    * Navigate to the Backend directory.
    * Install the required Python packages: pip install -r requirements.txt.
    * Set environment variables for database and APNs configuration.
    * Run the Flask app: flask run.
* iOS App Setup:
    * Open the project in Xcode using the `.xcworkspace` file, not the `.xcodeproj` file, to ensure all dependencies are correctly linked. 
    * Configure the project with your Apple Developer account to enable APNs.
    * Update the backend API URL in the iOS project to point to your Flask app.
    * Run the app on an iOS device or simulator.
* API Key Information: 
    * This project uses a free, limited-use API key for coinapi.io, which is subject to request limitations (100 requests per day). While this key is sufficient for demonstration purposes and initial exploration of the project, frequent use or testing might exceed these limits. If you encounter rate-limiting issues or prefer to use your own API key: Visit coinapi.io to obtain a personal API key and replace the API key in the project.
* Notes on Testing: 
    * For this project, I've put together a suite of unit tests to cover all the main functionalities. You'll notice that 9 out of 44 tests, specifically those related to the UI like AlertPresenter and Navigator, are currently off. Mocking UI and navigation turned out trickier than expected, and I opted to disable these tests for now. This way, it keeps the focus on the working parts of the app without the noise from those pesky, unresolved tests. I'm on the lookout for better testing strategies for these UI components and keen to refine the testing suite as I learn more. It's all part of the journey to making this app as robust as it can be.
