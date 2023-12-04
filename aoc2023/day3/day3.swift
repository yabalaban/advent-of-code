//
//  day3.swift
//  aoc2023
//

import Foundation

struct Point: Hashable {
    var x: Int
    var y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

func parsePartNumbers(_ schema: [String]) -> [Int] {
    var symbols = Set<Point>()
    schema.enumerated().forEach { (i, line) in
        line.enumerated().forEach { (j, ch) in
            if !ch.isNumber && ch != "." {
                let points = [
                    Point(i - 1, j - 1),
                    Point(i - 1, j),
                    Point(i - 1, j + 1),
                    Point(i, j - 1),
                    Point(i, j),
                    Point(i, j + 1),
                    Point(i + 1, j - 1),
                    Point(i + 1, j),
                    Point(i + 1, j + 1),
                ].filter({ $0.x >= 0 && $0.x < schema.count && $0.y >= 0 && $0.y < line.count })
                points.forEach({symbols.insert($0)})
            }
        }
    }
    
    var out: [Int] = []
    var isPart = false
    var number = ""
    schema.enumerated().forEach { (i, line) in
        line.enumerated().forEach { (j, ch) in
            if ch.isNumber {
                isPart = isPart || symbols.contains(Point(i, j))
                number += String(ch)
            } else {
                if isPart && !number.isEmpty {
                    out.append(Int(number)!)
                }
                isPart = false
                number = ""
            }
        }
    }
    return out
}

func parseGearsNumbers(_ schema: [String]) -> [[Int]] {
    var gears = [Point: Point]()
    schema.enumerated().forEach { (i, line) in
        line.enumerated().forEach { (j, ch) in
            if ch == "*" {
                let points = [
                    Point(i - 1, j - 1),
                    Point(i - 1, j),
                    Point(i - 1, j + 1),
                    Point(i, j - 1),
                    Point(i, j + 1),
                    Point(i + 1, j - 1),
                    Point(i + 1, j),
                    Point(i + 1, j + 1),
                ].filter({ $0.x >= 0 && $0.x < schema.count && $0.y >= 0 && $0.y < line.count })
                points.forEach({ gears[$0] = Point(i, j) })
            }
        }
    }
    
    var ratios: [Point: [Int]] = [:]
    var geared: Point? = nil
    var number = ""
    schema.enumerated().forEach { (i, line) in
        line.enumerated().forEach { (j, ch) in
            if ch.isNumber {
                if geared == nil {
                    geared = gears[Point(i, j)]
                }
                number += String(ch)
            } else {
                if let gear = geared {
                    ratios[gear, default: []].append(Int(number)!)
                }
                geared = nil
                number = ""
            }
        }
        if let gear = geared {
            ratios[gear, default: []].append(Int(number)!)
        }
        geared = nil
        number = ""
    }
    
    return Array(ratios.values)
}

func problem_3a() async throws -> Int {
    guard let url = Bundle.main.url(forResource: "day3", withExtension: "txt") else {
        fatalError()
    }
    
    { // assertions
        assert(parsePartNumbers([
            "467..114..",
            "...*......",
            "..35..633.",
            "......#...",
            "617*......",
            ".....+.58.",
            "..592.....",
            "......755.",
            "...$.*....",
            ".664.598..",
        ]).reduce(0, +) == 4361)
    }()
    var schema = [String]()
    for try await line in url.lines {
        schema.append(line)
    }
    return parsePartNumbers(schema).reduce(0, +)
}

func problem_3b() async throws -> Int {
    guard let url = Bundle.main.url(forResource: "day3", withExtension: "txt") else {
        fatalError()
    }
    
    { // assertions
        assert(parseGearsNumbers([
            "467..114..",
            "...*......",
            "..35..633.",
            "......#...",
            "617*......",
            ".....+.58.",
            "..592.....",
            "......755.",
            "...$.*....",
            ".664.598..",
        ]).filter({ $0.count > 1 }).map({ $0[0] * $0[1] }).reduce(0, +) == 467835)
    }()
    var schema = [String]()
    for try await line in url.lines {
        schema.append(line)
    }
    return parseGearsNumbers(schema).filter({ $0.count > 1 }).map({ $0[0] * $0[1] }).reduce(0, +)
}

