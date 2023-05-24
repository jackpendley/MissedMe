//
//  RegisterView.swift
//  App
//
//  Created by Daniel Fichtl on 3/9/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct RegisterView: View {
    
    @State var path = NavigationPath()
    
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var password: String = ""
    @State var confirm_password: String = ""
    @State var email: String = ""
    @State var bio: String = "User Bio. Add social media accounts, contact information, or other information you want your friends to be able to see"
    @State var isEditingBio = false
    @State private var image: Image? // state variable to store the selected image
    @State private var showingImagePicker = false
    @State private var inputImage : UIImage?
    
    
    
    var isRegisterButtonDisabled: Bool {
        [email, password, firstName, lastName, confirm_password].contains(where: \.isEmpty)
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                TextField("First Name", text: $firstName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                TextField("Last Name", text: $lastName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                SecureField("Confirm Password", text: $confirm_password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                TextEditor(text: $bio)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .foregroundColor(isEditingBio ? .black : .gray)
                    .padding(.horizontal)
                    .onTapGesture {
                        if bio == "User Bio. Add social media accounts, contact information, or other information you want your friends to be able to see" {
                            bio = ""
                        }
                        isEditingBio = true
                    }
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .frame(width: 360, height: 100)
                    Text("Select a Picture")
                        .foregroundColor(.gray)
                    image?
                        .resizable()
                        .scaledToFit()
                    Button(action: {
                        showingImagePicker = true
                    }, label: {
                        Color.clear
                    })
                } //Zstack
                Spacer()
                Group{
                    Button(action: {
                        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                            if let error = error {
                                print("Error registering user: \(error.localizedDescription)")
                                return
                            }
                            guard let user = authResult?.user else {
                                print("Error registering user: no user data returned")
                                return
                            }
                            print("User registered successfully with email: \(user.email ?? "unknown email")")
                            let db = Firestore.firestore()
                            guard let imageData = inputImage?.jpegData(compressionQuality: 0.3)
                            else {
                                print("error uploading image")
                                return // handle error, such as inputImage being nil
                            }
                            db.collection("Users").document(email).collection("Friends").document("Requested").setData([:]) { error in
                                if let error = error {
                                    print("Error creating subcollection: \(error.localizedDescription)")
                                } else {
                                    print("Subcollection doc created successfully!")
                                }
                            }
                            db.collection("Users").document(email).collection("Connections")
                            
                            db.collection("Users").document(email).setData(["username": firstName + lastName as String,
                                                                                                                         "firstName": firstName as String,
                                                                                                                         "lastName": lastName as String,
                                                                                                                         "bio": bio as String,
                                                                            
                                                                            "email": email as String,
                                                                        "timestamp": Timestamp(date: Date()),
                                                                                                                         "image": imageData]) { error in
                                if let error = error {
                                    print("Error adding user: \(error.localizedDescription)")
                                } else {
                                    print("User added successfully!")
                                        
                                    currentUser = email
                                    print(currentUser)
                                    path.append("HomeView")
                                }
                            }
                        } //auth Create user
                    } //button
                    ) {
                        Text("Register")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: 340)
                            .padding()
                            .cornerRadius(20)
                            .background(
                                isRegisterButtonDisabled ? // how to add a gradient to a button in SwiftUI if the button is disabled
                                LinearGradient(colors: [.gray], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                    LinearGradient(colors: [.blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(height: 50)
                            .frame(maxWidth: 340)
                            .cornerRadius(20)
                    }
                    .disabled(isRegisterButtonDisabled)
                } //Group
            } //Vstack
            .onChange(of: inputImage) { _ in loadImage() }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
            .navigationDestination(for: String.self) { view in
                if view == "HomeView"
                {
                    HomeView().navigationBarBackButtonHidden(true)
                }
            }
        }// Navstack

    } //some view
    
    func loadImage(){
        guard let inputImage = inputImage else {return}
        image = Image(uiImage: inputImage)
    }
} //Register
    
    
    
    
    
    struct Login_Previews: PreviewProvider {
        static var previews: some View {
            RegisterView()
        }
    }

