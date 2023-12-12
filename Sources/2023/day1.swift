func extractCalibrationNumber(from input: String) -> Int {
    func solution(_ input: String) -> Int {
        let digits = input
            .filter({ $0.isNumber })
            .compactMap({ Int($0.asciiValue! - Character("0").asciiValue!) })
        return digits[0] * 10 + digits[digits.count - 1]
    }
    
    assert(solution("1abc2") == 12)
    assert(solution("pqr3stu8vwx") == 38)
    assert(solution("a1b2c3d4e5f") == 15)
    assert(solution("treb7uchet") == 77)
    
    return input
        .split(separator: "\n")
        .map(String.init)
        .map(solution)
        .reduce(0, +)
}

func extractCalibrationNumberExtended(from input: String) -> Int {
    func solution(_ input: String) -> Int {
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
    
    assert(solution("two1nine") == 29)
    assert(solution("eightwothree") == 83)
    assert(solution("abcone2threexyz") == 13)
    assert(solution("xtwone3four") == 24)
    assert(solution("4nineeightseven2") == 42)
    assert(solution("zoneight234") == 14)
    assert(solution("7pqrstsixteen") == 76)
    assert(solution("38onexslhfourvttrfeightsqthree") == 33)
    assert(solution("44fivevpqtslbxkskhftmk") == 45)
    assert(solution("three8nmmp9threeeightwohft") == 32)
    assert(solution("97fourtwo") == 92)
    assert(solution("one5six6") == 16)
    assert(solution("nineight") == 98)
    
    return input
        .split(separator: "\n")
        .map(String.init)
        .map(solution(_:))
        .reduce(0, +)
}
