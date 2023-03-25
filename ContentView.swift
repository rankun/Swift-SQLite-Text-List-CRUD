import SwiftUI
import SQLite

struct TextItem: Identifiable {
    var id = UUID()
    var text: String
}

class TextList: ObservableObject {
    private let db: Connection
    private let itemsTable = Table("items")
    private let id = Expression<String>("id")
    private let text = Expression<String>("text")
    
    @Published var items: [TextItem] = []
    
    init() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            db = try Connection("\(path)/db.sqlite3")
            try createTable()
            try loadItems()
        } catch {
            print("Error initializing database: \(error)")
            fatalError()
        }
    }
    
    private func createTable() throws {
        try db.run(itemsTable.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(text)
        })
    }
    
    private func loadItems() throws {
        items = try db.prepare(itemsTable).map { row in
            TextItem(id: UUID(uuidString: row[id])!, text: row[text])
        }
    }
    
    func create(text: String) {
        let newItem = TextItem(text: text)
        do {
            try db.run(itemsTable.insert(id <- newItem.id.uuidString, self.text <- newItem.text))
            items.append(newItem)
        } catch {
            print("Error inserting item: \(error)")
        }
    }
    
    func update(id: UUID, newText: String) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].text = newText
            do {
                let item = itemsTable.filter(self.id == id.uuidString)
                try db.run(item.update(self.text <- newText))
            } catch {
                print("Error updating item: \(error)")
            }
        }
    }
    
    func delete(id: UUID) {
        items.removeAll(where: { $0.id == id })
        do {
            let item = itemsTable.filter(self.id == id.uuidString)
            try db.run(item.delete())
        } catch {
            print("Error deleting item: \(error)")
        }
    }
}

struct ContentView:  SwiftUI.View {
    @StateObject private var textList = TextList()
    @State private var newText = ""
    @State private var editItem: TextItem? = nil
    @State private var editText = ""
    
    var body: some  SwiftUI.View {
        NavigationView {
            List {
                TextField("Add new text", text: $newText, onCommit: {
                    textList.create(text: newText)
                    newText = ""
                })
                
                ForEach(textList.items) { item in
                    Text(item.text)
                        .onTapGesture {
                            editText = item.text
                            editItem = item
                        }
                }
                .onDelete(perform: { indexSet in
                    indexSet.forEach { index in
                        let id = textList.items[index].id
                        textList.delete(id: id)
                    }
                })
            }
            .navigationTitle("Text List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
        .sheet(item: $editItem) { item in
            NavigationView {
                Form {
                    TextField("Edit text", text: $editText, onCommit: {
                        if let id = editItem?.id {
                            textList.update(id: id, newText: editText)
                        }
                        editItem = nil
                    })
                }
                .navigationTitle("Edit Text")
                .navigationBarItems(trailing: Button("Done") {
                    if let id = editItem?.id {
                        textList.update(id: id, newText: editText)
                    }
                    editItem = nil
                })
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some  SwiftUI.View {
        ContentView()
    }
}
