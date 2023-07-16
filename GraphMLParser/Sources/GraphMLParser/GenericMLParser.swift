//
// GenericXMLParser.swift
// 
//
// Created by Kamil Zaborowski on 08/07/2023
// Copyright © 2023 Kamil Zaborowski. All rights reserved.
//

import Foundation

public struct GraphConfig: Codable {
    public var directed: Bool
    
    public init(directed: Bool) {
        self.directed = directed
    }
}

public struct GraphEdge: Codable {
    public var source: GraphNode.ID
    public var target: GraphNode.ID
    
    public init(source: GraphNode.ID, target: GraphNode.ID) {
        self.source = source
        self.target = target
    }
}

public struct GraphNode: Identifiable, Codable {
    public var id: String
    public var attributes: [String: String]
    public var elements: [GenericElement]
    
    public init(id: String, attributes: [String: String], elements: [GenericElement]) {
        self.id = id
        self.attributes = attributes
        self.elements = elements
    }
}

public protocol GraphMLParserDelegate: AnyObject {
    func graphMLParser(parsed graph: GraphConfig) throws
    func graphMLParser(parsed node: GraphNode) throws
    func graphMLParser(parsed edge: GraphEdge) throws
    func graphMLParserDidCompleted()
}

public struct GenericElement: Codable {
    public var name: String
    public var attributes: [String: String]
    public var text: String?
    public var children: [GenericElement]
}

public protocol GraphParser {
    var delegate: GraphMLParserDelegate? { get set }
    func parse(url: URL) throws
}
 
public class GraphMLParserImpl: NSObject, GraphParser, XMLParserDelegate {
    private var elementStack: [GenericElement] = []
    private var text: String = ""
    
    private var saveError: Error?
    
    public weak var delegate: GraphMLParserDelegate?
    
    public func parse(url: URL) throws {
        reset()
        
        let parser = XMLParser(contentsOf: url)
        parser?.delegate = self
        parser?.parse()
        
        if let saveError {
            throw saveError
        }
    }
    
    public func parserDidEndDocument(_ parser: XMLParser) {
        delegate?.graphMLParserDidCompleted()
    }
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == "graph" {
            let directed = attributeDict["edgedefault"] == "directed"
            let graph = GraphConfig(directed: directed)
            
            do {
                try delegate?.graphMLParser(parsed: graph)
            } catch {
                saveError = error
                parser.abortParsing()
            }

            elementStack = []
            text = ""
            
            return
        }
        
        let currentElement = GenericElement(name: elementName, attributes: attributeDict, children: [])
        elementStack.append(currentElement)
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        text += string
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard var element = elementStack.popLast() else {
            return
        }
        
        element.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        text = ""
        
        if element.name == "node" {
            let attributes = element.attributes
            let id = attributes["id"]!
            let elements = element.children
            let node = GraphNode(id: id, attributes: attributes, elements: elements)
            
            do {
                try delegate?.graphMLParser(parsed: node)
            } catch {
                saveError = error
                parser.abortParsing()
            }
        } else if element.name == "edge" {
            let attributes = element.attributes
            
            let source = attributes["source"]!
            let target = attributes["target"]!
            
            let edge = GraphEdge(source: source, target: target)
            
            do {
                try delegate?.graphMLParser(parsed: edge)
            } catch {
                saveError = error
                parser.abortParsing()
            }
        } else if element.name == "graph" {
            // do nothing
        } else if elementStack.count > 0 {
            let lastIndex = elementStack.count - 1
            elementStack[lastIndex].children.append(element)
        }
    }
    
    private func reset() {
        elementStack = []
        text = ""
        saveError = nil
    }
}
