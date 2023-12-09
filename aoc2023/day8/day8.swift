//
//  day8.swift
//  aoc2023
//

import Foundation

func countHops(_ config: String) -> Int {
    let comp = config.split(separator: "\n\n")
    
    var map: [String: (String, String)] = [:]
    for hop in comp.last!.split(separator: "\n") {
        let nodes = hop.split(separator: " = ")
        let head = String(nodes.first!)
        let child = nodes.last!.split(separator: ", ").map({ $0.trimmingCharacters(in: .letters.inverted) })
        map[head] = (child[0], child[1])
    }
    
    var count = 0
    var node = "AAA"
    while node != "ZZZ" {
        for ch in comp.first! {
            node = ch == "L" ? map[node]!.0 : map[node]!.1
            count += 1
        }
    }
    return count
}

func countHopsGhosts(_ config: String) -> Int {
    func gcd(_ a: Int, _ b: Int) -> Int {
        var a = a
        var b = b
        while b != 0 {
            (a, b) = (b, a % b)
        }
        return a
    }
    
    func lcm(_ a: Int, _ b: Int) -> Int {
        a * b / gcd(a, b)
    }
    
    func lcm(_ n: [Int]) -> Int {
        var res = lcm(n[0], n[1])
        for i in 2..<n.count {
            res = lcm(n[i], res)
        }
        return res
    }
    
    let comp = config.split(separator: "\n\n")
    
    var map: [String: (String, String)] = [:]
    for hop in comp.last!.split(separator: "\n") {
        let nodes = hop.split(separator: " = ")
        let head = String(nodes.first!)
        let child = nodes.last!.split(separator: ", ").map({ $0.trimmingCharacters(in: .alphanumerics.inverted) })
        map[head] = (child[0], child[1])
    }
    
    let nodes = map.keys.filter({ $0.hasSuffix("A") })
    let counts = nodes.map({
        var count = 0
        var node = $0
        while !node.hasSuffix("Z") {
            for ch in comp.first! {
                node = ch == "L" ? map[node]!.0 : map[node]!.1
                count += 1
            }
        }
        return count
    })
    return lcm(counts)
}

func problem_8a() async throws -> Int {
    guard let url = Bundle.main.url(forResource: "day8", withExtension: "txt") else {
        fatalError()
    }
    
    { // assertions
        assert(countHops("""
LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)
""") == 6)
    }()
    
    let input = try String(contentsOfFile: url.path(), encoding: .utf8)
    return countHops(input)
}

func problem_8b() async throws -> Int {
    guard let url = Bundle.main.url(forResource: "day8", withExtension: "txt") else {
        fatalError()
    }
    
    { // assertions
        assert(countHopsGhosts("""
LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)
""") == 6)
    }()
    
    let input = try String(contentsOfFile: url.path(), encoding: .utf8)
    return countHopsGhosts(input)
}

