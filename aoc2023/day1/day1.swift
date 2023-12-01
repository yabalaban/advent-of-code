//
//  day1.swift
//  aoc2023
//

import Foundation

func extractCalibrationNumber(from input: String) -> Int {
    let digits = input
        .filter({ $0.isNumber })
        .compactMap({ Int($0.asciiValue! - Character("0").asciiValue!) })
    return digits[0] * 10 + digits[digits.count - 1]
}

func extractCalibrationNumberExtended(from input: String) -> Int {
    let digits = [
        "zero": 0,
        "one": 1,
        "two": 2,
        "three": 3,
        "four": 4,
        "five": 5,
        "six": 6,
        "seven": 7,
        "eight": 8,
        "nine": 9,
    ]
    var input = input
    var d = [Int]()
    
    while input.count > 0 {
        if let p = digits.first(where: { input.hasPrefix($0.key) }) {
            d.append(p.value)
            input.removeFirst()
        } else {
            let ch = input.removeFirst()
            if ch.isNumber {
                d.append(Int(ch.asciiValue! - Character("0").asciiValue!))
            }
        }
    }
    
    return d[0] * 10 + d[d.count - 1]
}

func problem_1a() async throws -> Int {
    guard let url = Bundle.main.url(forResource: "day1", withExtension: "txt") else {
        fatalError()
    }
    { // assertions
        assert(extractCalibrationNumber(from: "1abc2") == 12)
        assert(extractCalibrationNumber(from: "pqr3stu8vwx") == 38)
        assert(extractCalibrationNumber(from: "a1b2c3d4e5f") == 15)
        assert(extractCalibrationNumber(from: "treb7uchet") == 77)
    }()
    return try await url.lines.map({ extractCalibrationNumber(from:$0) }).reduce(0, +)
}

func problem_1b() async throws -> Int {
    guard let url = Bundle.main.url(forResource: "day1", withExtension: "txt") else {
        fatalError()
    }
    { // assertions
        assert(extractCalibrationNumberExtended(from: "two1nine") == 29)
        assert(extractCalibrationNumberExtended(from: "eightwothree") == 83)
        assert(extractCalibrationNumberExtended(from: "abcone2threexyz") == 13)
        assert(extractCalibrationNumberExtended(from: "xtwone3four") == 24)
        assert(extractCalibrationNumberExtended(from: "4nineeightseven2") == 42)
        assert(extractCalibrationNumberExtended(from: "zoneight234") == 14)
        assert(extractCalibrationNumberExtended(from: "7pqrstsixteen") == 76)
        assert(extractCalibrationNumberExtended(from: "38onexslhfourvttrfeightsqthree") == 33)
        assert(extractCalibrationNumberExtended(from: "44fivevpqtslbxkskhftmk") == 45)
        assert(extractCalibrationNumberExtended(from: "three8nmmp9threeeightwohft") == 32)
        assert(extractCalibrationNumberExtended(from: "97fourtwo") == 92)
        assert(extractCalibrationNumberExtended(from: "one5six6") == 16)
        assert(extractCalibrationNumberExtended(from: "nineight") == 98)
    }()
    return try await url.lines.map({ extractCalibrationNumberExtended(from: $0) }).reduce(0, +)
}
