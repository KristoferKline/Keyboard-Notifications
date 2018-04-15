//
//  ViewController.swift
//  KeyboardNotifications
//
//  Created by Kristofer Kline on 4/14/18.
//  Copyright © 2018 Kristofer Kline. All rights reserved.
//

import UIKit

// MARK: - View Controller
class ViewController : UIViewController {
    var keyboardHeight: CGFloat = 0
    let inputField = UITextField()
    
    // MARK: - View Life Cycle
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .lightGray
        defer { self.view = view }
        
        inputField.backgroundColor = UIColor.white
        inputField.delegate = self
        inputField.frame = CGRect(x: 0, y: 400, width: UIScreen.main.bounds.width, height: 44)
        inputField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 44))
        inputField.leftViewMode = .always
        inputField.placeholder = "Type something..."
        view.addSubview(inputField)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    // MARK: - Keyboard Methods
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        // Note: This should always pass, could probably force cast.
        guard let info = notification.userInfo,
            let keyboardFrame = info[UIKeyboardFrameEndUserInfoKey] as? CGRect,
            let animationDuration = info[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else {
                return print("\(#function): Notification user info invalid.")
        }
        
        // Return early if the textfield is not obstructed by the keyboard.
        keyboardHeight = keyboardFrame.height
        var visibleFrame = view.frame
        visibleFrame.size.height -= keyboardHeight
        guard !visibleFrame.contains(inputField.frame.origin) else {
            return print("\(#function): Keyboard isn't overlapping.")
        }
        
        let offset = inputField.frame.maxY - view.frame.size.height
        UIView.animate(withDuration: animationDuration) { self.view.frame.origin.y += offset }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        guard let animationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return print("\(#function): Could not get the keyboard animation duration.")
        }
        
        UIView.animate(withDuration: animationDuration) { self.view.frame.origin.y = 0 }
    }
}

// MARK: - Textfield Delegate Methods
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
