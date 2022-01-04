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

    var body: some View {
        NavigationView {
            List {
                ForEach(self.goals) { item in
                    NavigationLink {
                        Text("Item at \(item.start!, formatter: itemFormatter)")
                    } label: {
                        Text(item.start!, formatter: itemFormatter)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Goal(context: self.viewContext)
            newItem.start = Date()

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
