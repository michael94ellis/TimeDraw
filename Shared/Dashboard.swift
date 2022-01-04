//
//  Dashboard.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/3/22.
//

import SwiftUI
import CoreData

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Goal.start, ascending: true)],
        animation: .default)
    private var goals: FetchedResults<Goal>
    
    @State var newItem: String = ""

    var body: some View {
        HStack {
            Button(action: addItem) {
                Label("", systemImage: "plus")
            }
            TextField("New Item", text: self.$newItem)
        }
        VStack {
            ForEach(self.goals) { item in
                Text(item.title ?? "No Title")
                Text(item.start!, formatter: itemFormatter)
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Goal(context: self.viewContext)
            newItem.start = Date()
            newItem.title = self.newItem
            do {
                try self.viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(_ indicies: IndexSet) {
        withAnimation {
            indicies.map { self.goals[$0] }.forEach(self.viewContext.delete)

            do {
                try self.viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
