//
//  WelcomeViewController.swift
//  CoinCaster
//
//  Created by Onyi Esu on 10/02/2024.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var progressView: UIProgressView!
    var progressTimer: Timer?
    var currentProgress: Float = 0.15

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgressView()
        startProgressTimer()
    }

    func setupProgressView() {
        progressView.setProgress(0.15, animated: false)
      }
    
    func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    @objc func updateProgress() {
        currentProgress += 0.05  // Increment progress
        progressView.setProgress(currentProgress, animated: true)
        
        if currentProgress >= 1  {
            invalidateTimer()
            
            // Transition to AuthOptionsViewController by setting it as the root view controller
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let authOptionsViewController = storyboard.instantiateViewController(withIdentifier: "AuthOptionsViewController") as? AuthOptionsViewController,
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let sceneDelegate = windowScene.delegate as? SceneDelegate {
            // Replace the entire screen with the AuthOptionsViewController
                sceneDelegate.window?.rootViewController = authOptionsViewController
            //Using a transition animation
               UIView.transition(with: sceneDelegate.window!, duration: 0.3, options: .transitionCrossDissolve, animations: {}, completion: nil)
            }
        }
    }
    
    func invalidateTimer() {
        progressTimer?.invalidate()
        progressTimer = nil // Setting the timer to nil to ensure it's fully released
    }
}
