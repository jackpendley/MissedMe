//
//  Connections.swift
//  App
//
//  Created by Daniel Herman on 1/26/23.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import CoreLocation


struct ConnectionsPage: View {
    @State var connections = [Connection]()
    @State var requestedByUser = Array<String>()
    @State var requestedTheUser = Array<String>()


    var body: some View {
        List(connections) { connection in
            ScrollView{
            VStack() {
                if let image = connection.profileImage
                {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 100, height: 100, alignment:.leading)
                        .clipShape(Circle())
                }
                Text(connection.name)
                    .font(.headline)
                Text("\(connection.Location)")
                    .font(.subheadline)
                //                Text("Bio: \(connection.Bio)")
                //                    .font(.subheadline)
                HStack {
                    //                    Button(action: {
                    //                        // Send message logic goes here
                    //                    }) {
                    //                        Text("Message")
                    //                    }
                    let isrequestedByUser = requestedByUser.contains(connection.username)
                    //                    let isrequestedByUser = false
                    let isrequestedTheUser = requestedTheUser.contains(connection.username)
                    //                    let isrequestedTheUser = false
                    if !isrequestedTheUser && isrequestedByUser {
                        Text("Friend Request Sent")
                    } else if !isrequestedTheUser && !isrequestedByUser {
                        Button(action: {
                            // Follow the user
                            let db = Firestore.firestore()
                            db.collection("Users").document(currentUser).collection("Friends").document("Requesting").setData([
                                "\(connection.username)": false
                            ]) { error in
                                if let error = error {
                                    print("Error following user: \(error.localizedDescription)")
                                } else {
                                    print("User followed successfully!")
                                    self.requestedByUser.append(connection.username)
                                }
                            }
                            // add to users followed document
                            db.collection("Users").document(connection.username).collection("Friends").document("Requested").setData([
                                currentUser: false
                            ]) { error in
                                if let error = error {
                                    print("Error adding other user followed: \(error.localizedDescription)")
                                } else {
                                    print("other Users followed doc add successfully!")
                                }
                            }
                        }) {
                            Text("Friend Request")
                        }
                    } else if !isrequestedByUser && isrequestedTheUser {
                        Button(action: {
                            // Follow back the user
                            let db = Firestore.firestore()
                            db.collection("Users").document(currentUser).collection("Friends").document("Requesting").setData([
                                connection.username: true
                            ]) { error in
                                if let error = error {
                                    print("Error following user: \(error.localizedDescription)")
                                } else {
                                    print("User followed successfully!")
                                    self.requestedByUser.append(connection.username)
                                }
                            }
                            // add to users followed document
                            db.collection("Users").document(connection.username).collection("Friends").document("Requested").setData([
                                currentUser: true
                            ]) { error in
                                if let error = error {
                                    print("Error adding other user followed: \(error.localizedDescription)")
                                } else {
                                    print("other Users followed doc add successfully!")
                                }
                            }
                            db.collection("Users").document(currentUser).collection("Friends").document("Requested").setData([
                                connection.username: true
                            ]) { error in
                                if let error = error {
                                    print("Error following user: \(error.localizedDescription)")
                                } else {
                                    print("User followed successfully!")
                                    self.requestedByUser.append(connection.username)
                                }
                            }
                            // add to users followed document
                            db.collection("Users").document(connection.username).collection("Friends").document("Requesting").setData([
                                currentUser: true
                            ]) { error in
                                if let error = error {
                                    print("Error adding other user followed: \(error.localizedDescription)")
                                } else {
                                    print("other Users followed doc add successfully!")
                                }
                            }
                        }) {
                            Text("Requested you, add friend?")
                        }
                    } else if isrequestedTheUser && isrequestedByUser {
                        Text("Friends :)")
                    }
                }
            }
        }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
        .onAppear {
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            getIsRequested { requestedTheUser in
                self.requestedTheUser = requestedTheUser
                print("HEYA PALS")
                print(self.requestedTheUser)
                dispatchGroup.leave()
            }
            dispatchGroup.enter()
            getIsRequesting { requestedByUser in
                self.requestedByUser = requestedByUser
                dispatchGroup.leave()
            }
            dispatchGroup.notify(queue: .main) {
                getConnectionsFromFirebase { connections in
                    self.connections = connections
                }
            }
            print("HEYA PALS")
            print(self.requestedTheUser)
        }
    }
}


struct Connection: Identifiable {
    let id = UUID()
    let name: String
    let Location: String
//    let Bio: String
    let profileImage: UIImage?
    let username: String
}

//struct Connections_Previews: PreviewProvider {
//    static var previews: some View {
//        ConnectionsPage(connections: [Connection(name: "John", Location: "Intramural Sports Building", Bio: "@Johnny"), Connection(name: "Jane", Location: "Bopjip", Bio: "@Jane")])
//
//    }
//}

func getConnectionsFromFirebase(completion: @escaping ([Connection]) -> Void) {
    let db = Firestore.firestore()
    var connections = [Connection]()
    var profileImage: UIImage?
    
    db.collection("Users").document(currentUser).collection("Connections").getDocuments() { querySnapshot, error in
        if let error = error {
            print("Error getting connections: \(error)")
        } else {
            for document in querySnapshot!.documents {
                let data = document.data()
                let username = data["email"] as! String
                let firstName = data["firstName"] as! String
                let timestamp = data["timestamp"] as! Timestamp
                
                let calendar = Calendar.current
                let comp = timestamp.dateValue()
                let Components = calendar.dateComponents([.year, .month, .day], from: comp)
                let currentComponents = calendar.dateComponents([.year, .month, .day], from: Date())
                let isCurrentDay = (Components.year == currentComponents.year &&
                    Components.month == currentComponents.month &&
                    Components.day == currentComponents.day)
                if !isCurrentDay {
                    continue
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .medium
                let location = dateFormatter.string(from: timestamp.dateValue())
//                let bio = data["bio"] as! String
                if let imageData = data["image"] as? Data {
                    profileImage = UIImage(data: imageData)
                } else {
                    print("Document does not exist")
                }// else
                print("THE USERNAME IN CONNECTION")
                print(username)
                connections.append(Connection(name: firstName, Location: location,
//                                              Bio: bio
                                              profileImage: profileImage,
                                              username: username))
            }
        }
        completion(connections)
    }
}

func getIsRequesting(completion: @escaping (Array<String>) -> Void) {
    let db = Firestore.firestore()
    var requestedByUser = [String]()

    db.collection("Users").document(currentUser).collection("Friends").document("Requesting").getDocument() { (document, error) in
        if let document = document, document.exists {
            let data = document.data()
            requestedByUser = data?.compactMap { $0.key } ?? []
        }
        completion(requestedByUser)
    }
}

func getIsRequested(completion: @escaping (Array<String>) -> Void) {
    let db = Firestore.firestore()
    var requestedTheUser = [String]()

    db.collection("Users").document(currentUser).collection("Friends").document("Requested").getDocument() { document, error in
        if let document = document, document.exists {
            let data = document.data()
            requestedTheUser = data?.compactMap { $0.key } ?? []
        }
        print("WHAT IN THE WORLD")
        print(requestedTheUser)
        completion(requestedTheUser)
    }
}


