
private func rowsMirror(_ rows: [String], _ allowed: Int = 0) -> Int? {
    func diff(_ s1: String, _ s2: String) -> Int {
        var delta = 0
        for i in 0..<s1.count {
            if s1[s1.index(s1.startIndex, offsetBy: i)] != s2[s2.index(s2.startIndex, offsetBy: i)] {
                delta += 1
            }
        }
        return delta
    }
    
    var candidates: [Int] = []
    
    for i in 1..<rows.count {
        if diff(rows[i], rows[i - 1]) <= allowed {
            candidates.append(i - 1)
        }
    }
    if candidates.count > 1 {
        print(candidates)
    }
    candidates = candidates.filter({ cand in
        var start = cand
        var d = 1
        var delta = 0
        while start >= 0 && (start + d) < rows.count && delta <= allowed {
            delta += diff(rows[start], rows[start + d])
            if delta > allowed {
                return false
            }
            start -= 1
            d += 2
        }
        return delta == allowed
    })
    
    return candidates.count > 0 ? candidates.first! + 1 : nil
}

private func colsMirror(_ cols: [String], _ allowed: Int = 0) -> Int? {
    var transposed = Array(repeating: "", count: cols[0].count)
    
    for i in 0..<cols.count {
        for j in 0..<transposed.count {
            let line = cols[i]
            if line.isEmpty {
                continue
            }
            transposed[j].append(line[line.index(line.startIndex, offsetBy: j)])
        }
    }
    
    return rowsMirror(transposed, allowed)
}

func getMirrorScore(_ input: String) -> Int {
    assert(colsMirror("""
#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.
""".components(separatedBy: "\n")) == 5)
    assert(rowsMirror("""
#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.
""".components(separatedBy: "\n")) == nil)
    assert(colsMirror("""
#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.
""".components(separatedBy: "\n")) == 5)
    assert(rowsMirror("""
#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#
""".components(separatedBy: "\n")) == 4)
    assert(colsMirror("""
#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#
""".components(separatedBy: "\n")) == nil)
    
    var xs = [0]
    var ys = [0]
    
    for pattern in input.components(separatedBy: "\n\n") {
        let lines = pattern.components(separatedBy: "\n").filter({ !$0.isEmpty })
        if let x = rowsMirror(lines) {
            xs.append(x)
        } else if let y = colsMirror(lines) {
            ys.append(y)
        }
    }
    
    return 100 * xs.reduce(0, +) + ys.reduce(0, +)
}

func getMirrorScoreWithDelta(_ input: String) -> Int {
    var xs = [0]
    var ys = [0]
    
    for pattern in input.components(separatedBy: "\n\n") {
        let lines = pattern.components(separatedBy: "\n").filter({ !$0.isEmpty })
        if let x = rowsMirror(lines, 1) {
            xs.append(x)
        } else if let y = colsMirror(lines, 1) {
            ys.append(y)
        }
    }
    
    return 100 * xs.reduce(0, +) + ys.reduce(0, +)
}
