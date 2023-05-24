import SwiftUI
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseFirestore
var currentUser = ""

struct AccountView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var bio = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var profileImage: UIImage?
    //    @State var bioString: Any = ""
    
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
    
    
    
    
    
    var body: some View {
        NavigationView{
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        do {
                            try Auth.auth().signOut()
                            // Navigate to login view or perform any other necessary actions after signout
                            print("Logout valid 1000000")
                            dismiss()
                        } catch {
                            print("Error signing out: \(error.localizedDescription)")
                        }
                    }) {
                        Text("Sign Out")
                            .bold()
                            .foregroundColor(.white)
                    }
                    .padding(20)
                    .frame(height: 44)
                    .background(Color.red)
                    .clipShape(Capsule())
                    .padding(.top, 20)
                    .padding(.trailing, 20)
                } //Hstack
                VStack {
                    HStack{
                        if let image = profileImage
                        {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 100, height: 100, alignment:.leading)
                                .clipShape(Circle())
                        }
                        Text("\(firstName) \(lastName)")
                            .font(.title)
                            .padding()
                    } // Hstack
                    Text("Bio: \(bio)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    Spacer()
                    NavigationLink(destination: EditAccountView()) {
                        Text("Edit Account")
                            .bold()
                            .foregroundColor(.white)
                    }
                    .padding(20)
                    .frame(height: 44)
                    .background(Color.blue)
                    .clipShape(Capsule())
                    .padding(.top, 20)
                    .padding(.leading, 8)
                    Spacer()
                } // Vstack
                .onAppear{
                    fetchUserData()
                } //onAppear
            } //Vstack
        } //navView
    } //some view
} //outside struct

struct Account_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
