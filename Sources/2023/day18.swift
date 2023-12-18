func cubicMeters(_ lines: [String]) -> Int {
    var ranges: [Int: [ClosedRange<Int>]] = [:]
    var start = (0, 0)
    
    for line in lines {
        let comp = line.components(separatedBy: " ")
        switch comp[0] {
        case "R":
            let len = Int(comp[1])!
            var rs = ranges[start.1, default: []]
            let nr = start.0...(start.0 + len)
            rs = rs.filter({ $0.clamped(to: nr) != $0 })
            if rs.allSatisfy({ nr.clamped(to: $0) != nr }) {
                rs.append(nr)
            }
            rs.sort(by: { $0.startIndex < $1.startIndex || ($0.startIndex == $1.startIndex && $0.endIndex >= $1.endIndex) })
            ranges[start.1] = rs
            start = (start.0 + len, start.1)
        case "L":
            let len = Int(comp[1])!
            var rs = ranges[start.1, default: []]
            let nr = (start.0 - len)...start.0
            rs = rs.filter({ $0.clamped(to: nr) != $0 })
            if rs.allSatisfy({ nr.clamped(to: $0) != nr }) {
                rs.append(nr)
            }
            rs.sort(by: { $0.startIndex < $1.startIndex || ($0.startIndex == $1.startIndex && $0.endIndex >= $1.endIndex) })
            ranges[start.1] = rs
            start = (start.0 - len, start.1)
        case "D":
            let len = Int(comp[1])!
            for i in start.1...(start.1 + len) {
                var rs = ranges[i, default: []]
                let nr = start.0...start.0
                rs = rs.filter({ $0.clamped(to: nr) != $0 })
                if rs.allSatisfy({ nr.clamped(to: $0) != nr }) {
                    rs.append(nr)
                }
                rs.sort(by: { $0.startIndex < $1.startIndex || ($0.startIndex == $1.startIndex && $0.endIndex >= $1.endIndex) })
                ranges[i] = rs
            }
            start = (start.0, start.1 + len)
        case "U":
            let len = Int(comp[1])!
            for i in (start.1 - len)...start.1 {
                var rs = ranges[i, default: []]
                let nr = start.0...start.0
                rs = rs.filter({ $0.clamped(to: nr) != $0 })
                if rs.allSatisfy({ nr.clamped(to: $0) != nr }) {
                    rs.append(nr)
                }
                rs.sort(by: { $0.startIndex < $1.startIndex || ($0.startIndex == $1.startIndex && $0.endIndex >= $1.endIndex) })
                ranges[i] = rs
            }
            start = (start.0, start.1 - len)
        default:
            fatalError()
        }
    }
    
    var count = 0
    var skip = true
    var pstep = 0
    var prow: [ClosedRange<Int>]? = nil
    for row in ranges.keys.sorted() {
        let prev = ranges[row - 1, default: []]
        let next = ranges[row + 1, default: []]
        if ranges[row]! == prow {
            count += pstep
            continue
        }
        prow = ranges[row]
        
        var step = 0
        for i in 0..<ranges[row]!.count {
            let range = ranges[row]![i]
            step += range.count
            
            let tb = prev.count > 0 ? prev.filter({ $0.overlaps(range) }).count : -1
            let bt = next.count > 0 ? next.filter({ $0.overlaps(range) }).count : -1
            
            if abs(tb) == 1 && abs(bt) == 1 {
                skip.toggle()
            }
            
            if !skip && i < ranges[row]!.count - 1 {
                let nrange = ranges[row]![i + 1]
                step += nrange.lowerBound - range.upperBound - 1
            }
        }
        count += step
        pstep = step
    }
    
    return count
}

func countCubicMeters(_ input: String) -> Int {
    assert(cubicMeters([
        "D 3 (#70c710)",
        "R 2 (#0dc571)",
        "U 1 (#5713f0)",
        "R 2 (#d2c081)",
        "D 1 (#59c680)",
        "R 2 (#411b91)",
        "U 3 (#8ceee2)",
        "L 6 (#caa173)",
    ]) == 27)
    assert(cubicMeters([
        "R 6 (#70c710)",
        "D 5 (#0dc571)",
        "L 2 (#5713f0)",
        "D 2 (#d2c081)",
        "R 2 (#59c680)",
        "D 2 (#411b91)",
        "L 5 (#8ceee2)",
        "U 2 (#caa173)",
        "L 1 (#1b58a2)",
        "U 2 (#caa171)",
        "R 2 (#7807d2)",
        "U 3 (#a77fa3)",
        "L 2 (#015232)",
        "U 2 (#7a21e3)",
    ]) == 62)
    
    let lines = input.components(separatedBy: "\n").filter({ !$0.isEmpty })
    return cubicMeters(lines)
}

private func decode(_ input: [String]) -> [String] {
    let val = input.map({
        var hex = $0.components(separatedBy: "#").last!
        _ = hex.removeLast() // ")"
        let d = hex.removeLast()
        let direction = if d == "0" {
            "R"
        } else if d == "1" {
            "D"
        } else if d == "2" {
            "L"
        } else if d == "3" {
            "U"
        } else {
            fatalError()
        }
        let distance = Int(hex, radix: 16)!
        return "\(direction) \(distance)"
    })
    return val
}

func countCubicMetersExtended(_ input: String) -> Int {
    assert(cubicMeters(decode([
        "R 6 (#70c710)",
        "D 5 (#0dc571)",
        "L 2 (#5713f0)",
        "D 2 (#d2c081)",
        "R 2 (#59c680)",
        "D 2 (#411b91)",
        "L 5 (#8ceee2)",
        "U 2 (#caa173)",
        "L 1 (#1b58a2)",
        "U 2 (#caa171)",
        "R 2 (#7807d2)",
        "U 3 (#a77fa3)",
        "L 2 (#015232)",
        "U 2 (#7a21e3)",
    ])) == 952408144115)
    
    let lines = input.components(separatedBy: "\n").filter({ !$0.isEmpty })
    return cubicMeters(decode(lines))
}
