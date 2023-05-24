//
//  Login.swift
//  App
//
//  Created by Daniel Chayes on 3/7/23.
//

import Foundation
import SwiftUI
import UIKit
import FirebaseFirestore
import FirebaseAuth

struct LoginView: View {
    @State var email: String = ""
    @State var password: String = ""
    @State var showPassword: Bool = false
    @State var isNavigating: Bool = false
    
    @State var path = NavigationPath()
    
    var isSignInButtonDisabled: Bool {
        [email, password].contains(where: \.isEmpty)
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 15) {
                Spacer() // this use all space available above the TextField
                
                TextField("Name",
                          text: $email,
                          prompt: Text("Email").foregroundColor(.blue))
                .padding(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.blue, lineWidth: 2)
                }
                .padding(.horizontal)
                
                HStack {
                    Group {
                        if showPassword { // when this changes, you show either TextField or SecureField
                            TextField("Password",
                                      text: $password,
                                      prompt: Text("Password").foregroundColor(.red)) // How to change the color of the TextField Placeholder
                        } else {
                            SecureField("Password", // how to create a secure text field
                                        text: $password,
                                        prompt: Text("Password").foregroundColor(.red)) // How to change the color of the TextField Placeholder
                        }
                    }
                    .padding(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.red, lineWidth: 2) // How to add rounded corner to a TextField and change it colour
                    }
                    
                    Button { // add this new button
                        showPassword.toggle()
                        print("Going to registration.")
                    } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.red)
                    }
                    
                }.padding(.horizontal)
                Spacer() // this use all space available below the TextField
                NavigationLink(destination: RegisterView()) {
                    Text("Don't have an account? Register!")
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, minHeight: 12)
                        .padding()
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                }
                VStack {
                    Button {
                        // handle the action of the button here
                        Auth.auth().signIn(withEmail: email, password: password) { result, error in
                            if let error = error {
                                // Handle error
                                
                                print("Error logging in: \(error.localizedDescription)")
                            } else {
                                // Login successful
                                print("Login successful!")
                                currentUser = email
                                path.append("HomeView")
                            }
                        }
                    } label: {
                        Text("Sign In                                                                             ")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                    }
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(
                        isSignInButtonDisabled ?
                        LinearGradient(colors: [.gray], startPoint: .topLeading, endPoint: .bottomTrailing) :
                            LinearGradient(colors: [.blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(20)
                    .disabled(isSignInButtonDisabled)
                    .padding()
                } //Zstack
            }// Vstack
            .navigationDestination(for: String.self) { view in
                if view == "HomeView"
                {
                    HomeView().navigationBarBackButtonHidden(true)
                }
            }

        } //navstack
//        .onAppear()
//        {
//            //if logged in skip login screen
//            if Auth.auth().currentUser != nil
//            {
//                print("Login successful!")
//                path.append("HomeView")
//            }
//        }
    } // SomeView
}// Login
