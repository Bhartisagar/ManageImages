import UIKit

class NotificationManager {
    
    static func showNotification(message: String, duration: TimeInterval = 3.0) {
        // Ensure UI updates are on the main thread
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else { return }

            // Create a custom notification banner
            let notificationView = UIView()
            notificationView.backgroundColor = .black
            notificationView.alpha = 0.9
            notificationView.layer.cornerRadius = 10
            
            // Set up the label for the message
            let label = UILabel()
            label.text = message
            label.textColor = .white
            label.numberOfLines = 0
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            notificationView.addSubview(label)

            // Create the OK button
            let okButton = UIButton(type: .system)
            okButton.setTitle("OK", for: .normal)
            okButton.setTitleColor(.white, for: .normal)
            okButton.translatesAutoresizingMaskIntoConstraints = false
            okButton.addTarget(self, action: #selector(dismissNotification(_:)), for: .touchUpInside)
            notificationView.addSubview(okButton)

            // Add the notification banner to the window
            window.addSubview(notificationView)
            notificationView.translatesAutoresizingMaskIntoConstraints = false

            // Set up layout constraints
            NSLayoutConstraint.activate([
                notificationView.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 20),
                notificationView.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -20),
                notificationView.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -50),
                
                label.leadingAnchor.constraint(equalTo: notificationView.leadingAnchor, constant: 10),
                label.trailingAnchor.constraint(equalTo: notificationView.trailingAnchor, constant: -10),
                label.topAnchor.constraint(equalTo: notificationView.topAnchor, constant: 10),
                
                okButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
                okButton.bottomAnchor.constraint(equalTo: notificationView.bottomAnchor, constant: -10),
                okButton.centerXAnchor.constraint(equalTo: notificationView.centerXAnchor)
            ])
            
            notificationView.transform = CGAffineTransform(translationX: 0, y: 100)
            UIView.animate(withDuration: 0.3, animations: {
                notificationView.transform = .identity
            })
        }
    }
    
    @objc private static func dismissNotification(_ sender: UIButton) {
        // Ensure UI updates are on the main thread
        DispatchQueue.main.async {
            if let notificationView = sender.superview {
                UIView.animate(withDuration: 0.3, animations: {
                    notificationView.alpha = 0
                }) { _ in
                    notificationView.removeFromSuperview()
                }
            }
        }
    }
}
