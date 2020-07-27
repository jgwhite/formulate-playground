//: A UIKit based Playground for presenting user interface

import SwiftUI
import PlaygroundSupport

struct Node: Hashable, Identifiable {
    let value: String?
    var childrenDict: [String: Node] = [:]
    var isComplete: Bool = false
    var count: Int = 0
    
    var id: String {
        return value ?? "[root]"
    }
    
    var children: [Node] {
        return Array(childrenDict.values)
    }
    
    init() {
        self.value = nil
    }
    
    init(_ value: String) {
        self.value = value
    }
    
    mutating func insert(_ values: Array<String>) {
        insert(ArraySlice(values))
    }
    
    mutating func insert(_ values: Array<Substring>) {
        insert(values.map { String($0) })
    }
    
    mutating func insert(_ values: ArraySlice<String>) {
        guard let head = values.first else {
            return
        }
        
        let tail = values.dropFirst()
        
        if childrenDict[head] == nil {
            childrenDict[head] = Node(head)
        }
        
        childrenDict[head]?.count += 1
        
        if (tail.isEmpty) {
            childrenDict[head]?.isComplete = true
        } else {
            childrenDict[head]?.insert(tail)
        }
    }
}

struct Line: Shape {
    let parent: CGRect
    let child: CGRect
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let dx = child.midX - parent.midX
        let ax = rect.midX - dx
        let bx = rect.midX
        
        path.move(to: CGPoint(x: ax, y: -20))
        
        path.addCurve(
            to: CGPoint(x: bx, y: 0),
            control1: CGPoint(x: ax, y: 0),
            control2: CGPoint(x: bx, y: -20)
        )
        
        return path
    }
}

struct NodeView: View {
    let node: Node
    let geo: GeometryProxy
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .center, spacing: 20) {
                ZStack {
                    Text("\(self.node.value!) (\(self.node.count))")
                        .fontWeight(.semibold)
                        .fixedSize()
                        .padding()
                        .background(self.colorScheme == .dark ? Color.black : Color.white)
                        .rounded()
                        .niceShadow()
                    Line(
                        parent: self.geo.frame(in: .global),
                        child: geo.frame(in: .global)
                    )
                        .stroke(
                            Color(red: 0.62, green: 0.68, blue: 0.75),
                            lineWidth: 3
                        )
                        .layoutPriority(0)
                }.fixedSize()
                HStack(alignment: .top) {
                    ForEach(self.node.children) { child in
                        NodeView(node: child, geo: geo)
                    }
                }
                Spacer()
            }
        }
    }
}

extension View {
    func niceShadow() -> some View {
        self
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 3)
            .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 3)
    }
    
    func rounded() -> some View {
        self
            .cornerRadius(12)
    }
}

struct RootView: View {
    let node: Node
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .center, spacing: 20) {
                ZStack {
                    Text("Root")
                        .fontWeight(.semibold)
                        .fixedSize()
                        .padding()
                        .background(self.colorScheme == .dark ? Color.black : Color.white)
                        .rounded()
                        .niceShadow()
                }
                HStack(alignment: .top) {
                    ForEach(self.node.children) { child in
                        NodeView(node: child, geo: geo)
                    }
                }
                Spacer()
            }
        }
    }
}

struct App: View {
    @State var node = Node()
    @State var formula = ""

    var body: some View {
        VStack {
            HStack {
                TextField(
                    "Formula",
                    text: $formula, onCommit: insertFormula
                )
                Button(
                    action: reset,
                    label: { Text("Reset") }
                )
            }
            .padding()
            RootView(node: node)
        }
        .frame(width: 512, height: 1024)
        .border(Color.gray)
    }
    
    func insertFormula() {
        let values = formula.split(separator: " ")
        node.insert(values)
        formula = ""
    }
    
    func reset() {
        node = Node()
    }
}

PlaygroundPage.current.setLiveView(App())
