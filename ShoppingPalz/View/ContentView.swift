//
//  ContentView.swift
//  ShoppingPalz
//
//  Created by Alfian Losari on 15/08/19.
//  Copyright © 2019 alfianlosari. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    
    @EnvironmentObject var list: ShoppingList
    @ObservedObject var connectionStatus = ConnectionStatus()
    @State var text: String = ""
    
    var body: some View {
        
        NavigationView {
            List {
                HStack {
                    Image(systemName: "circle.fill")
                        .foregroundColor(self.connectionStatus.isOnline ? .green : .red)
                    Text(self.connectionStatus.isOnline ? "Online" : "Offline")
                        
                }
                
                HStack {
                    TextField("Add new item", text: $text)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Add") {
                        self.createItem()
                    }
                    .foregroundColor(.blue)
                }
                
                if (!self.list.items.pending.isEmpty) {
                    SectionItemsView(title: "Pending", items: self.list.items.pending, onTap: self.onTap, onDelete: self.onDelete)
                }
                
                if (!self.list.items.purchased.isEmpty) {
                    SectionItemsView(title: "Purchased", items: self.list.items.purchased, onTap: self.onTap, onDelete: self.onDelete)
                }
            }
            .onAppear {
                self.list.startListener()
                self.connectionStatus.startListening()
            }
            .onDisappear {
                self.list.stopListener()
                self.connectionStatus.stopListening()
            }
            .navigationBarTitle("Shopping Cart ⚡️")
        }
    }
    
    func createItem() {
        guard !self.text.isEmpty else {
            return
        }
        
        let item = Item(id: UUID().uuidString, text: self.text, isPurchased: false, updatedBy: "Alfian", updatedAt: Date())
        self.list.addItem(item)
        self.text = ""
    }
    
    func onTap(item: Item) {
        self.list.updateItem(item)
    }
    
    func onDelete(item: Item) {
        self.list.removeItem(item)
    }
}

struct SectionItemsView: View {
    
    var title: String
    var items: [Item]
    var onTap: ((Item) -> ())
    var onDelete: ((Item) -> ())
    
    var body: some View {
        Section(header: Text(title)) {
            ForEach(self.items, id: \.diff) { item in
                Button(action: {
                    self.onTap(item)
                }) {
                    HStack {
                        Text(item.text)
                        Spacer()
                        Image(systemName: item.isPurchased ? "checkmark.circle.fill" : "circle")
                    }
                }
            }
            .onDelete { (indexSet) in
                indexSet.forEach {
                    self.onDelete(self.items[$0])
                }
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
