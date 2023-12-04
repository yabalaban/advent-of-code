//
//  day4.swift
//  aoc2023
//

import Foundation

func countPoints(_ card: String) -> Int {
    let comp = card.split(separator: ": ").last?.split(separator: " | ")
    let winning = Set(comp?.first?.split(separator: " ").compactMap({ Int($0) }) ?? [])
    let inp = Set(comp?.last?.split(separator: " ").compactMap({ Int($0) }) ?? [])
    let match = winning.intersection(inp)
    
    if match.count > 0 {
        return  1 << (match.count - 1)
    } else {
        return 0
    }
}

func countScratchcard(_ card: String, _ state: inout [Int: Int]) {
    let comp = card.split(separator: ": ")
    let id = Int(comp.first!.split(separator: " ").last!)!
    let numbers = comp.last!.split(separator: " | ")
    let winning = Set(numbers.first?.split(separator: " ").compactMap({ Int($0) }) ?? [])
    let inp = Set(numbers.last?.split(separator: " ").compactMap({ Int($0) }) ?? [])
    let match = winning.intersection(inp).count
    
    let bump = state[id, default: 0] + 1
    state[id] = bump
    if match > 0 {
        for i in (id + 1)...(id + match) {
            state[i] = state[i, default: 0] + bump
        }
    }
}

func problem_4a() async throws -> Int {
    guard let url = Bundle.main.url(forResource: "day4", withExtension: "txt") else {
        fatalError()
    }
    
    { // assertions
        assert(countPoints("Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53") == 8)
        assert(countPoints("Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19") == 2)
        assert(countPoints("Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1") == 2)
        assert(countPoints("Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83") == 1)
        assert(countPoints("Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36") == 0)
        assert(countPoints("Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11") == 0)
    }()
    return try await url.lines.compactMap({ countPoints($0) }).reduce(0, +)
}

func problem_4b() async throws -> Int {
    guard let url = Bundle.main.url(forResource: "day4", withExtension: "txt") else {
        fatalError()
    }
    
    { // assertions
        var state = [Int: Int]()
        let cards = [
            "Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53",
            "Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19",
            "Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1",
            "Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83",
            "Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36",
            "Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11",
        ]
        cards.forEach({ countScratchcard($0, &state) })
        assert(state.values.reduce(0, +) == 30)
    }()
    var state = [Int: Int]()
    for try await line in url.lines {
        countScratchcard(line, &state)
    }
    return state.values.reduce(0, +)
}

