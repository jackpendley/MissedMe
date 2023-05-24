//
//  editAccountView.swift
//  App
//
//  Created by Daniel Chayes on 4/4/23.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseFirestore
import Foundation

struct EditAccountView: View {
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var bio: String = "User Bio. Add social media accounts, contact information, or other information you want your friends to be able to see"
    @State private var image: Image? // state variable to store the selected image
    @State private var showingImagePicker = false
    @State private var inputImage : UIImage?
    @State var isEditingBio = false
    @State private var profileImage: UIImage?
    func loadImage(){
        guard let inputImage = inputImage else {return}
        image = Image(uiImage: inputImage)
    }
    func fetchUserData() {
        let db = Firestore.firestore()
        let docRef = db.collection("Users").document(currentUser)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                
                // JACK debug attempt
                print("DATA:", data ?? "")
                print(data?["bio"])
                
                //                  if data?.contains(where: { $0.key == "bio" }) == true {
                //                          if let bioValue = data!["bio"] {
                //                              // Make sure bioValue is a string
                //                              if let bioString = bioValue as? String {
                //                                  bio = bioString
                //                              }
                //                          }
                //                      }
                print("BIO", bio)
                //                  var bioValue = data!["bio"]
                //                  bioString = bioValue as? String
                //                  print("bioString", bioString)
                bio = data?["bio"]  as? String ?? ""
                firstName = data?["firstName"] as? String ?? ""
                lastName = data?["lastName"] as? String ?? ""
                if let imageData = data?["image"] as? Data {
                    profileImage = UIImage(data: imageData)
                } else {
                    print("issue grabbing image")
                    //                      print(currentUser)
                }// else
            }// if
            else{
                print("Document does not exist")
            }
        } // docref
    } //func
    var body: some View{
        Text("Edit Account")
                    .font(.title)
                    .fontWeight(.bold)
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
        
        Button(action: {
            let db = Firestore.firestore()
            let imageData = inputImage?.jpegData(compressionQuality: 0.3)
            db.collection("Users").document(currentUser).setData(["username": firstName + lastName as String,
                                                                                                         "firstName": firstName as String,
                                                                                                         "lastName": lastName as String,
                                                                                                         "bio": bio as String,
                                                                                                         "image": imageData])
                   }) {
                       Text("Save Changes")
                           .bold()
                           .foregroundColor(.white)
                   }
                   .frame(width: 200, height: 44)
                   .background(Color.blue)
                   .clipShape(Capsule())
                   .padding(.top, 20)
                   .padding(.horizontal, 8)
        Spacer()
        .onAppear{
            fetchUserData()
        } //onAppear
        .onChange(of: inputImage) { _ in loadImage() }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
        }
        Spacer()
    }
}

struct EditPreviews: PreviewProvider {
    static var previews: some View {
        EditAccountView()
    }
}

