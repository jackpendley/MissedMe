//  friends.swift
//  App
//
//  Created by Daniel Herman on 1/26/23.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth


struct FriendsView: View {
    @State var friends = [friend]()
    
    var body: some View {
        List(friends) { friend in
            VStack() {
                if let image = friend.profileImage
                {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 100, height: 100, alignment:.leading)
                        .clipShape(Circle())
                }
                Text(friend.firstName + " " + friend.lastName)
                    .font(.headline)
                Text("Contact Info: \(friend.Bio)")
                    .font(.subheadline)
                HStack {
                    Button(action: {
                        // Follow the user
                        let db = Firestore.firestore()
                        db.collection("Users").document(currentUser).collection("Friends").document("Requesting").setData([
                            "\(friend.username)": FieldValue.delete()
                        ], merge: true) { error in
                            if let error = error {
                                print("Error unfollowing user: \(error.localizedDescription)")
                            } else {
                                print("User unfollowed successfully!")
                            }
                        }
                        db.collection("Users").document(currentUser).collection("Friends").document("Requested").setData([
                            "\(friend.username)": false
                        ]) { error in
                            if let error = error {
                                print("Error unfollowing user: \(error.localizedDescription)")
                            } else {
                                print("User unfollowed successfully!")
                            }
                        }
                        // add to users followed document
                        db.collection("Users").document(friend.username).collection("Friends").document("Requested").setData([
                            "\(currentUser)": FieldValue.delete()
                        ], merge: true) { error in
                            if let error = error {
                                print("Error unfollowing user: \(error.localizedDescription)")
                            } else {
                                print("User unfollowed successfully!")
                            }
                        }
                        db.collection("Users").document(friend.username).collection("Friends").document("Requesting").setData([
                            currentUser: false
                        ]) { error in
                            if let error = error {
                                print("Error adding other user followed: \(error.localizedDescription)")
                            } else {
                                print("other Users unfollowed doc add successfully!")
                            }
                        }
                        friends.removeAll(where: { $0.id == friend.id })
                    }) {
                        Text("Unfollow")
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
        .onAppear {
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
                getFriendsFromFirebase { friends in
                    print("FRIENDS")
                    print(friends)
                    self.friends = friends
                    dispatchGroup.leave()
                }
            dispatchGroup.notify(queue: .main) {
            }
        }
    }
}


struct friend: Identifiable {
    let id = UUID()
    let firstName: String
    let lastName: String
    let Bio: String
    let profileImage: UIImage?
    let username: String
}

//struct friends_Previews: PreviewProvider {
//    static var previews: some View {
//        friendsPage(friends: [friend(name: "John", Location: "Intramural Sports Building", Bio: "@Johnny"), friend(name: "Jane", Location: "Bopjip", Bio: "@Jane")])
//
//    }
//}

func getFriendsFromFirebase(completion: @escaping ([friend]) -> Void) {
    let db = Firestore.firestore()
    var friends = [friend]()
    var keys = [String]()
    let dispatchGroup = DispatchGroup()
    
    db.collection("Users").document(currentUser).collection("Friends").document("Requested").getDocument() { (document, error) in
        if let document = document, document.exists {
            let data = document.data()
            keys = data?.compactMap { $0.key }.filter { data?[$0] as? Bool == true } ?? []
            
            for key in keys {
                dispatchGroup.enter()
                db.collection("Users").document(key).getDocument { document, error in
                    if let document = document, document.exists {
                        let data = document.data()
                        let username = data?["email"] as! String
                        let firstName = data?["firstName"] as! String
                        let lastName = data?["lastName"] as! String
                        let bio = data?["bio"] as! String
                        var profileImage: UIImage?
                        if let imageData = data?["image"] as? Data {
                            profileImage = UIImage(data: imageData)
                        }
                        friends.append(friend(firstName: firstName, lastName: lastName, Bio: bio,
                                              profileImage: profileImage,
                                              username: username))
                    } else {
                        print("No such document: requested")
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(friends)
            }
        } else {
            print("No such keys: requested")
            completion([])
        }
    }
}
