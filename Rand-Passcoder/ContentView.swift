//
//  ContentView.swift
//  Rando-Passcoder
//
//  Created by MidState Software on 10/7/24.
//  Author: Seth L. Farrington, Copyright (C) 2024, All rights reserved.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State private var password: String = ""
    @State private var passcode: String = ""
    @State private var showPasswordChangeAlert = false
    @State private var passwordHidden = true
    @State private var passcodeHidden = true
    @State private var binaryDigits: [String] = []

    let passwordKey = "savedPassword"
    let passcodeKey = "savedPasscode"

    var body: some View {
        ZStack {
            // Background with oversized random binary digits
            Color.black.ignoresSafeArea()

            GeometryReader { geometry in
                ForEach(binaryDigits.indices, id: \.self) { index in
                    Text(binaryDigits[index])
                        .font(.system(size: 80))
                        .foregroundColor(Color.green.opacity(0.8))
                        .position(x: CGFloat.random(in: 0...geometry.size.width), y: CGFloat.random(in: 0...geometry.size.height))
                }
            }

            VStack(spacing: 20) {
                // Title
                Text("Rando-Passcoder")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
                    .bold()
                    .multilineTextAlignment(.center)

                // App description
                Text("Randomized individual iOS Passcode/Password generation utility with sharing and saving capability. Click to regenerate new codes, long-press to share to systems.")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .bold()
                    .multilineTextAlignment(.leading)

                VStack(spacing: 10) {
                    // Password Group
                    Group {
                        if password.isEmpty {
                            Text("Password: ")
                                .bold()
                                .foregroundColor(.red) +
                            Text("Generate")
                                .italic()
                                .foregroundColor(.yellow)
                        } else if passwordHidden {
                            Text("Password: ••••••••••••••")
                                .bold()
                                .foregroundColor(.red)
                        } else {
                            Text("Password: \(password)")
                                .font(.system(size: 22))
                                .bold()
                                .foregroundColor(.black) // Change text color to black
                                .padding()
                                .background(Color.white) // Background color for the password
                                .cornerRadius(10)
                                .textSelection(.enabled) // Enable text selection
                        }
                    }
                    .onTapGesture {
                        if passwordHidden {
                            generatePassword() // Generate new password if visible
                        }
                    }

                    // Hide/Show Password Button
                    Button(action: {
                        passwordHidden.toggle()
                    }) {
                        Text(passwordHidden ? "Show Password" : "Hide Passcode / Click Dots to Regenerate")
                            .foregroundColor(.red)
                            .bold()
                    }

                    // Passcode Group
                    Group {
                        if passcode.isEmpty {
                            Text("Passcode: ")
                                .bold()
                                .foregroundColor(.red) +
                            Text("Generate")
                                .italic()
                                .foregroundColor(.yellow)
                        } else if passcodeHidden {
                            Text("Passcode: ••••••")
                                .bold()
                                .foregroundColor(.red)
                        } else {
                            Text("Passcode: \(passcode)")
                                .font(.system(size: 22))
                                .bold()
                                .foregroundColor(.black) // Change text color to black
                                .padding()
                                .background(Color.white) // Background color for the passcode
                                .cornerRadius(10)
                                .textSelection(.enabled) // Enable text selection
                        }
                    }
                    .onTapGesture {
                        if passcodeHidden {
                            generatePasscode() // Generate new passcode if visible
                        }
                    }

                    // Hide/Show Passcode Button
                    Button(action: {
                        passcodeHidden.toggle()
                    }) {
                        Text(passcodeHidden ? "Show Passcode" : "Hide Passcode / Click Dots to Regenerate")
                            .foregroundColor(.red)
                            .bold()
                    }
                }

                // Copy and change buttons
                Button(action: copyPasswordAndOpenSettings) {
                    Text("Copy & Change Password")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .bold()
                }

                Button(action: copyPasscodeAndOpenSettings) {
                    Text("Copy & Change Passcode")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .bold()
                }
            }
            .padding()
            .alert(isPresented: $showPasswordChangeAlert) {
                Alert(
                    title: Text("Change Required"),
                    message: Text("The new password and passcode have been copied to your clipboard.\n\nTo change your password or passcode, please open the Settings app."),
                    dismissButton: .default(Text("OK"))
                )
            }

            // Footer Text: Developed by MidState Software Co.
            VStack {
                Spacer()
                Text("Developed by MidState Software Co.\n(C) Copyright 2024, all rights reserved.")
                    .font(.footnote)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
            }
        }
        .onAppear {
            generateRandomBinaryDigits()
            loadSavedCredentials() // Load saved password and passcode
        }
        .onDisappear {
            saveCredentials() // Save password and passcode when exiting
        }
    }

    // Generate a specified number of random binary digits
    func generateRandomBinaryDigits() {
        binaryDigits = (0..<50).map { _ in Bool.random() ? "1" : "0" }
    }

    // Generate random password
    func generateRandomPassword() -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()"
        return String((0..<16).compactMap { _ in characters.randomElement() })
    }

    // Generate random passcode
    func generateRandomPasscode() -> String {
        return String(format: "%06d", arc4random_uniform(1000000))
    }

    // Generate new password
    func generatePassword() {
        password = generateRandomPassword()
        passwordHidden = false // Show the password once generated
        saveCredentials() // Save credentials when generated
    }

    // Generate new passcode
    func generatePasscode() {
        passcode = generateRandomPasscode()
        passcodeHidden = false // Show the passcode once generated
        saveCredentials() // Save credentials when generated
    }

    // Copy password to clipboard and open settings
    func copyPasswordAndOpenSettings() {
        UIPasteboard.general.string = password
        openSettings()
    }

    // Copy passcode to clipboard and open settings
    func copyPasscodeAndOpenSettings() {
        UIPasteboard.general.string = passcode
        openSettings()
    }

    // Open system settings to the main settings screen
    func openSettings() {
        if let url = URL(string: "App-Prefs:") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    // Save password and passcode locally
    func saveCredentials() {
        UserDefaults.standard.set(password, forKey: passwordKey)
        UserDefaults.standard.set(passcode, forKey: passcodeKey)
    }

    // Load saved password and passcode
    func loadSavedCredentials() {
        if let savedPassword = UserDefaults.standard.string(forKey: passwordKey),
           let savedPasscode = UserDefaults.standard.string(forKey: passcodeKey) {
            password = savedPassword
            passcode = savedPasscode
            passwordHidden = true
            passcodeHidden = true // Obfuscate on load
        }
    }

    // Function to share text via message or email in Times New Roman, black, not bolded
    func shareText(text: String) {
        let attributedString = NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont(name: "Times New Roman", size: 18) ?? UIFont.systemFont(ofSize: 18),
                .foregroundColor: UIColor.black
            ]
        )
        
        let activityVC = UIActivityViewController(activityItems: [attributedString], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            keyWindow.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
    }
}

// Main entry point for SwiftUI App
@main
struct PasswordGeneratorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
