Cryptocurrency Price Alert App

Overview
This project is a comprehensive iOS application designed to notify users when Bitcoin reaches a specified target price. Built with Swift and leveraging the iOS SDK, the app integrates a Flask backend to manage user registrations, login sessions, and target price alerts. The application showcases robust Object-Oriented Programming (OOP) practices, API design, multithreading for asynchronous tasks, and effective mobile memory management.

Features
* User Authentication: Supports user registration and login, ensuring secure access to the app.
* Target Price Alerts: Allows users to set a target price for Bitcoin. When the current price crosses this target, the user receives a push notification.
* APNs Integration: Utilizes Apple Push Notification service (APNs) for delivering real-time price alerts.
* Persistent User Sessions: Implements persistent sessions using UserDefaults and Keychain, enhancing the user experience by retaining session state across app restarts.
* Dynamic Price Updates: Integrates with a cryptocurrency API to fetch live Bitcoin prices, enabling users to make informed decisions when setting target alerts.

Technical Details
* Language: Swift for iOS app development, Python (Flask) for the backend service.
* Architecture: MVC (Model-View-Controller) for organized and maintainable codebase.
* Networking: URLSession for handling API requests to both the cryptocurrency API and the custom Flask backend.
* Data Persistence: UserDefaults for simple data storage, Keychain for secure storage of sensitive information like user tokens.
* Push Notifications: Configuration and handling of APNs for sending and receiving notifications.
* Concurrency: Utilization of asynchronous programming patterns to maintain UI responsiveness and handle network requests.
* API Design: Flask RESTful API design for managing user data, authentication, and target price alerts.

Setup and Configuration

Prerequisites
* Xcode
* Swift
* Python 3 and Flask for the backend
* An APNs certificate for push notifications

Running the Project
* Backend Setup:
    * Navigate to the Flask app directory.
    * Install the required Python packages: pip install -r requirements.txt.
    * Set environment variables for database and APNs configuration.
    * Run the Flask app: flask run.
* iOS App Setup:
    * Open the .xcodeproj file in Xcode.
    * Configure the project with your Apple Developer account to enable APNs.
    * Update the backend API URL in the iOS project to point to your Flask app.
    * Run the app on an iOS device or simulator.
