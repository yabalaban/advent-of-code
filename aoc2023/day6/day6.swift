//
//  day6.swift
//  aoc2023
//

import Foundation

func numberOfWaysToBeat(_ time: Double, _ distance: Double) -> Int {
    // (time - x) * x = distance
    // time * x - x * x - distance = 0
    // -x * x + time * x - distsance = 0
    //
    // x^2 - time * x + distance = 0
    let d = sqrt(time * time - 4.0 * distance)
    let s1 = (-time - d) / -2.0
    let s2 = (-time + d) / -2.0
    let ub = ceil(s1) - 1
    let lb = floor(s2) + 1
    return Int(ub - lb) + 1
}

func problem_6a() async throws -> Int {
    guard let url = Bundle.main.url(forResource: "day6", withExtension: "txt") else {
        fatalError()
    }
    { // assertions
        assert(numberOfWaysToBeat(7, 9) == 4)
        assert(numberOfWaysToBeat(15, 40) == 8)
        assert(numberOfWaysToBeat(30, 200) == 9)
    }()

    let doc = try String(contentsOfFile: url.path(), encoding: .utf8)
    let lines = doc.split(separator: "\n")
    let times = lines.first!.split(separator: ":").last!.split(separator: " ").compactMap({ Double($0) })
    let distances = lines.last!.split(separator: ":").last!.split(separator: " ").compactMap({ Double($0) })
    return zip(times, distances).map(numberOfWaysToBeat).reduce(1, *)
}

func problem_6b() async throws -> Int {
    { // assertions
        assert(numberOfWaysToBeat(71530, 940200) == 71503)
    }()
    return numberOfWaysToBeat(40828492, 233101111101487)
}

