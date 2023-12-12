func extrapolate(_ input: [Int], f: ([Int], Int) -> Int) -> Int {
    func delta(_ input: [Int]) -> Int {
        if input.allSatisfy({ $0 == 0 }) { return 0 }
        let d = (1..<input.count).map({ input[$0] - input[$0 - 1] })
        return f(d, delta(d))
    }
    return f(input, delta(input))
}


func extrapolateRight(_ input: String) -> Int {
    { // assertions
        assert(extrapolate([0, 3, 6, 9, 12, 15], f: { $0.last! + $1 }) == 18)
        assert(extrapolate([1, 3, 6, 10, 15, 21], f: { $0.last! + $1 }) == 28)
        assert(extrapolate([10, 13, 16, 21, 30, 45], f: { $0.last! + $1 }) == 68)
    }()
    
    return input
        .split(separator: "\n")
        .map({ $0.split(separator: " ") })
        .map({ $0.compactMap({ Int($0) }) })
        .map({ extrapolate($0, f: { $0.last! + $1 }) })
        .reduce(0, +)
}

func extrapolateLeft(_ input: String) -> Int {
    { // assertions
        assert(extrapolate([10, 13, 16, 21, 30, 45], f: { $0.first! - $1 }) == 5)
    }()
    
    return input
        .split(separator: "\n")
        .map({ $0.split(separator: " ") })
        .map({ $0.compactMap({ Int($0) }) })
        .map({ extrapolate($0, f: { $0.first! - $1 }) })
        .reduce(0, +)
}

