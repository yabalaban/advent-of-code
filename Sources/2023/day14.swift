private class Point2D: Equatable {
    static func == (lhs: Point2D, rhs: Point2D) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    var x: Int
    var y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

func countLoadOnNorth2(_ input: String, _ spins: Int) -> Int {
    let rows = input.components(separatedBy: "\n").filter({ !$0.isEmpty })
    var mirrors: [Point2D] = []
    var beams: [Point2D] = []
    
    for (y, row) in rows.enumerated() {
        for (x, ch) in row.enumerated() {
            if ch == "#" {
                beams.append(Point2D(x, y))
            }
            if ch == "O" {
                mirrors.append(Point2D(x, y))
            }
        }
    }
    
    var state = (0..<rows[0].count).map({ _ in [Point2D(0, -1)] })
    for beam in beams {
        if beam.y != 0 {
            state[beam.x].append(Point2D(0, beam.y))
        }
    }
    
    for mirror in mirrors {
        let cols = state[mirror.x]
        var slot = cols[0]
        for beam in cols {
            if mirror.y > beam.y {
                slot = beam
            } else {
                break
            }
        }
        slot.x += 1
    }
    
    var c = 0
    for col in state {
        c += col.filter({ $0.x != 0 }).map({ (slot) in
            var total = slot.x
            var cost = rows.count - slot.y - 1
            var sum = 0
            while total > 0 {
                sum += cost
                cost -= 1
                total -= 1
            }
            return sum
        }).reduce(0, +)
    }
    c -= rows[0].count
    return c
}

func countLoadOnNorth(_ input: String, _ spins: Int) -> Int {
    var beams: [Int: [(Int, Int)]] = [:]
    let rows = input.components(separatedBy: "\n").filter({ !$0.isEmpty })
    for i in 0..<rows[0].count {
        beams[i, default: []].append((0, rows.count))
    }
    for (y, row) in rows.enumerated() {
        for (i, ch) in row.enumerated() {
            if ch == "#" {
                beams[i, default: []].append((0, rows.count - y - 1))
            }
            if ch == "O" {
                if let stack = beams[i] {
                    let top: (Int, Int)
                    if let last = stack.last {
                        top = (last.0 + 1, last.1)
                    } else {
                        top = (1, rows.count - y)
                    }
                    beams[i]?[stack.count - 1] = top
                } else {
                    fatalError()
                }
            }
        }
    }
    var c = 0
    for beam in beams.values {
        c += beam.map({ (total, top) in
            var total = total
            var cost = top
            var sum = 0
            while total > 0 {
                sum += cost
                cost -= 1
                total -= 1
            }
            return sum
        }).reduce(0, +)
    }
    return c
}

func totalLoadOnNorth(_ input: String) -> Int {
//    assert(countLoadOnNorth2("""
//OO.
//..O
//""", 1) == 6)
    assert(countLoadOnNorth2("""
O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....
""", 1) == 136)
    return countLoadOnNorth2(input, 1)
}

func totalLoadOnNorthWithSpins(_ input: String) -> Int {
//    assert(countLoadOnNorth("""
//O....#....
//O.OO#....#
//.....##...
//OO.#O....O
//.O.....O#.
//O.#..O.#.#
//..O..#O..O
//.......O..
//#....###..
//#OO..#....
//""", 1000000000) == 64)
    return countLoadOnNorth(input, 1000000000)
}
