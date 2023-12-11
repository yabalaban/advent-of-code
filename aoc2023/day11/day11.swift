//
//  day11.swift
//  aoc2023
//

import Foundation

private func totalDistance(_ galaxy: String, coef: Int = 2) -> Int {
    let coord = galaxy
        .split(separator: "\n").enumerated()
        .map({ ($0, $1.enumerated().filter({ $1 == "#" })) })
        .filter({ !$1.isEmpty })
        .map({ y, xs in xs.map({ (y, $0.offset) }) })
        .flatMap({ $0 })
    var pairs: [(Int, Int)] = []
    for i in 0..<(coord.count - 1) {
        for j in (i + 1)..<coord.count {
            pairs.append((i, j))
        }
    }
    let rowdup = {
        let xs = coord.map({ $0.0 })
        return Set(0..<xs.max()!).subtracting(xs)
    }()
    let coldup = {
        let ys = coord.map({ $0.1 })
        return Set(0..<ys.max()!).subtracting(ys)
    }()
    let sum = pairs.map({ pair in
        let p1 = coord[pair.0]
        let p2 = coord[pair.1]
        let rawX = abs(p1.0 - p2.0)
        let rawY = abs(p1.1 - p2.1)
        let expX = rowdup.intersection((min(p1.0, p2.0))...(max(p1.0, p2.0))).count * (coef - 1)
        let expY = coldup.intersection((min(p1.1, p2.1))...(max(p1.1, p2.1))).count * (coef - 1)
        return rawX + rawY + expX + expY
    }).reduce(0, +)
    return sum
}

func problem_11a() async throws -> Int {
    guard let url = Bundle.main.url(forResource: "day11", withExtension: "txt") else {
        fatalError()
    }
    
    { // assertions
        assert(totalDistance("""
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
""") == 374);
    }()
    
    let input = try String(contentsOfFile: url.path(), encoding: .utf8)
    return totalDistance(input)
}

func problem_11b() async throws -> Int {
    guard let url = Bundle.main.url(forResource: "day11", withExtension: "txt") else {
        fatalError()
    }
    
    { // assertions
        assert(totalDistance("""
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
""", coef: 10) == 1030);
        assert(totalDistance("""
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
""", coef: 100) == 8410);
    }()
    
    let input = try String(contentsOfFile: url.path(), encoding: .utf8)
    return totalDistance(input, coef: 1000000)
}
