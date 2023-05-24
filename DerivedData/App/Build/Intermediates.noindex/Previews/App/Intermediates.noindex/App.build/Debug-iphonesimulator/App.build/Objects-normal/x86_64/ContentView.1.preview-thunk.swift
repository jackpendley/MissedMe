@_private(sourceFile: "ContentView.swift") import App
import CoreData
import SwiftUI
import SwiftUI

extension ContentView_Previews {
    @_dynamicReplacement(for: previews) private static var __preview__previews: some View {
        #sourceLocation(file: "/Users/daniel/Desktop/EECS/441/App/App/ContentView.swift", line: 87)
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    
#sourceLocation()
    }
}

extension ContentView {
    @_dynamicReplacement(for: deleteItems(offsets:)) private func __preview__deleteItems(offsets: IndexSet) {
        #sourceLocation(file: "/Users/daniel/Desktop/EECS/441/App/App/ContentView.swift", line: 63)
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    
#sourceLocation()
    }
}

extension ContentView {
    @_dynamicReplacement(for: addItem()) private func __preview__addItem() {
        #sourceLocation(file: "/Users/daniel/Desktop/EECS/441/App/App/ContentView.swift", line: 47)
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    
#sourceLocation()
    }
}

extension ContentView {
    @_dynamicReplacement(for: body) private var __preview__body: some View {
        #sourceLocation(file: "/Users/daniel/Desktop/EECS/441/App/App/ContentView.swift", line: 20)
        VStack {
            Text(__designTimeString("#8565.[2].[2].property.[0].[0].arg[0].value.[0].arg[0].value", fallback: "MEET'R"))
            HStack {
                /*Button(action: {
                    
                }, label: {
                    Image("appmap")
                })
                .frame(width: 30, height: 30)*/
                Button(__designTimeString("#8565.[2].[2].property.[0].[0].arg[0].value.[1].arg[0].value.[0].arg[0].value", fallback: "Map")){
                    
                }
                Button(__designTimeString("#8565.[2].[2].property.[0].[0].arg[0].value.[1].arg[0].value.[1].arg[0].value", fallback: "Connections")) {
                    
                }
                Button(__designTimeString("#8565.[2].[2].property.[0].[0].arg[0].value.[1].arg[0].value.[2].arg[0].value", fallback: "Messages")) {
                    
                }
                Button(__designTimeString("#8565.[2].[2].property.[0].[0].arg[0].value.[1].arg[0].value.[3].arg[0].value", fallback: "Account")) {
                    
                }
                
        }.frame(maxHeight: .infinity, alignment: .bottom)
    }
    
#sourceLocation()
    }
}

import struct App.ContentView
import struct App.ContentView_Previews
