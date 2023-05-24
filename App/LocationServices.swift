import SwiftUI
import CoreLocation
import Firebase
import FirebaseFirestore

var regionRadiusglob = 0.0
class LocationManager: NSObject, CLLocationManagerDelegate {
    let locationManagerInstance = CLLocationManager()
    let firestoreDB = Firestore.firestore()
    let regionRadius = regionRadiusglob // in meters
    var currentUserEmail = currentUser
    var currentUserLocation = CLLocation(latitude: 0.0, longitude: 0.0)

    func setupLocationManager() {
        locationManagerInstance.requestAlwaysAuthorization()
        locationManagerInstance.delegate = self
        // Get initial location
        print("RIGHT BEFORE")
        if let location = locationManagerInstance.location {
            self.currentUserLocation = location
            print("Initial location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            let db = Firestore.firestore()
            db.collection("Users").document(currentUser).updateData([
                "location": self.currentUserLocation.description
            ]) { error in
                if let error = error {
                    print("Error unfollowing user: \(error.localizedDescription)")
                } else {
                    print("User unfollowed successfully!")
                }
            }
        }
        // Schedule the locationManager function to be called every 60 seconds
        //DispatchQueue.main.asyncAfter(deadline: .now() + 60.0) {
            self.locationManager()
        //}
    }


    func addOtherUserToConnectionsSubcollection(email: String, location: CLLocation, userTime: Timestamp) {
        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(self.currentUserEmail)
        let connectionsRef = userRef.collection("Connections")
        let currTime = Timestamp(date: Date())
        let timestamp = currTime.compare(userTime) == .orderedAscending ? currTime : userTime
        let otherUserDocID = email
        var currUserFName = ""
        var currprofileImage: Data?
        var otherUserFName = ""
        var otherprofileImage: Data?
        
        
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        userRef.getDocument() { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                currUserFName = data?["firstName"] as! String
                currprofileImage = data?["image"] as? Data
            }
           
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        db.collection("Users").document(email).getDocument() { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                otherUserFName = data?["firstName"] as! String
                otherprofileImage = data?["image"] as? Data
            }
            
            
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {

            connectionsRef.document(otherUserDocID).setData([
                "email": email,
                "image": otherprofileImage,
                "firstName": otherUserFName,
                "location": "EECS Building",
                "timestamp": timestamp
            ])
            
            db.collection("Users").document(email).collection("Connections").document(self.currentUserEmail).setData([
                "email": self.currentUserEmail,
                "image": currprofileImage,
                "firstName": currUserFName,
                "location": "EECS Building",
                "timestamp": timestamp
            ])
        }


        
        print("ADDED MORE USERS TO CONNECTIONS")
    }

    func isOtherUserInRegion(otherUserLocation: CLLocation) -> Bool {
        print("RANGE DIFFERENCE")
        print(self.currentUserLocation.distance(from: otherUserLocation))
        return self.currentUserLocation.distance(from: otherUserLocation) <= self.regionRadius
    }
    
    func isCurrentDate(_ date: Date) -> Bool {
            let calendar = Calendar.current
            let currentDateOnly = calendar.dateComponents([.year, .month, .day], from: Date())
            let lastDate = calendar.dateComponents([.year, .month, .day], from: date)
            return currentDateOnly.year == lastDate.year &&
               currentDateOnly.month == lastDate.month &&
               currentDateOnly.day == lastDate.day
        }

    func locationManager() {
        print("HELP ME PLEASEEEEE")
        let db = Firestore.firestore()
        db.collection("Users").document(currentUser).updateData([
            "location": self.currentUserLocation.description,
            "timestamp": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("Error unfollowing user: \(error.localizedDescription)")
            } else {
                print("User location stored successfully!")
            }
        }
        
        // Check if other user is in region and add other user to connections subcollection
        db.collection("Users").getDocuments() { querySnapshot, error in
            if let error = error {
                print("Error getting connections: \(error)")
            } else {

                for document in querySnapshot!.documents {
                    let email = document.documentID
                    if email != self.currentUserEmail{
                        print("WHAT THEIR EMAIL")
                        print(email)
                        if let str = document.get("location") as? String {
                            let userTime = document.get("timestamp") as! Timestamp
                            if self.isCurrentDate(userTime.dateValue()){
                                let regex = try! NSRegularExpression(pattern: "<(.+)>")
                                let match = regex.firstMatch(in: str, range: NSRange(str.startIndex..., in: str))!
                                let coordsString = String(str[Range(match.range(at: 1), in: str)!])
                                let coordsArray = coordsString.components(separatedBy: ",")
                                let latitude = Double(coordsArray[0])!
                                let longitude = Double(coordsArray[1])!
                                let otherUserLocation = CLLocation(latitude: latitude, longitude: longitude)
                                
                                if self.isOtherUserInRegion(otherUserLocation: otherUserLocation) {
                                print("SHOWS THEY ARE SAME LOCATION")
                                    self.addOtherUserToConnectionsSubcollection(email: email, location: otherUserLocation, userTime: userTime)
                            }
                        }
                        }
                    }
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 60.0) {
            self.locationManager()
        }
    }
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let currentLocation = locations.last else { return }
//        self.currentUserLocation = currentLocation
//    }
}
