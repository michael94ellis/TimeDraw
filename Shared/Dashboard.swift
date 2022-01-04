////
////  Dashboard.swift
////  TimeDraw
////
////  Created by Michael Ellis on 1/3/22.
////
//
//import SwiftUI
//import CoreData
//
//struct DashboardView: View {
//    
//    @State var newItem: String = ""
//
//    var body: some View {
//        VStack {
//            VStack {
//                ForEach(self.goals) { item in
//                    Text(item.title ?? "No Title")
//                    Text(item.start!, formatter: itemFormatter)
//                }
//            }
//            Spacer()
//            HStack {
//                Button(action: addItem) {
//                    Label("", systemImage: "plus")
//                }
//                TextField("Add an event", text: self.$newItem)
//            }
//        }
//    }
//
//    private func addItem() {
//        withAnimation {
//            let newItem = Goal(context: self.viewContext)
//            newItem.start = Date()
//            newItem.title = self.newItem
//            do {
//                try self.viewContext.save()
//            } catch {
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//
//    private func deleteItems(_ indicies: IndexSet) {
//        withAnimation {
//            indicies.map { self.goals[$0] }.forEach(self.viewContext.delete)
//
//            do {
//                try self.viewContext.save()
//            } catch {
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//}
//
//private let itemFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    formatter.timeStyle = .medium
//    return formatter
//}()
