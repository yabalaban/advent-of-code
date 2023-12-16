private class Point2D: Equatable, Hashable, CustomStringConvertible {
    static func == (lhs: Point2D, rhs: Point2D) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    var x: Int
    var y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    
    var description: String {
        "(\(x), \(y))"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

func countLoadOnNorth(_ input: String, _ spins: Int) -> Int {
    func tiltToNorth(_ mirrors: [Point2D], _ beams: [Point2D], _ n: Int) -> [Point2D] {
        var state = (0..<n).map({ _ in [Point2D(0, 0)] })
        
        for beam in beams {
            state[beam.x].append(Point2D(0, beam.y + 1))
        }
        
        for mirror in mirrors {
            let cols = state[mirror.x]
            var slot = cols[0]
            for beam in cols {
                if mirror.y >= beam.y {
                    slot = beam
                } else {
                    break
                }
            }
            slot.x += 1
        }
        
        var new: [Point2D] = []
        for (x, col) in state.enumerated() {
            col.filter({ $0.x != 0 }).forEach({ (slot) in
                var total = slot.x
                var cost = rows.count - max(slot.y, 0)
                var sum = 0
                while total > 0 {
                    sum += cost
                    new.append(Point2D(x, rows.count - cost))
                    cost -= 1
                    total -= 1
                }
            })
        }
        
        return new
    }
    
    func rotate(_ mirrors: [Point2D], _ beams: [Point2D], _ len: Int) -> ([Point2D], [Point2D]) {
        let rmirrors = mirrors.map({ Point2D(len - 1 - $0.y, $0.x) })
        let rbeams = beams.map({ Point2D(len - 1 - $0.y, $0.x) })
        return (rmirrors, rbeams)
    }
    
    func load(_ mirrors: [Point2D], _ beams: [Point2D]) -> Int {
        var c = 0
        for x in 0..<rows[0].count {
            var loading = true
            for y in 0..<rows.count {
                if loading && mirrors.contains(where: { $0 == Point2D(x, y) }) {
                    c += rows.count - y
                } else {
                    loading = true
                }
                if beams.contains(where: { $0 == Point2D(x, y) }) {
                    loading = true
                }
            }
        }
        return c
    }
    
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
    
    if spins > 0 {
        var spins = spins
        while spins > 0 {
            var rbeams = beams
            var rmirrors = mirrors
            rmirrors = tiltToNorth(rmirrors, rbeams, rows[0].count)
            (rmirrors, rbeams) = rotate(rmirrors, rbeams, rows[0].count)
            rmirrors.sort(by: { $0.x < $1.x || ($0.x >= $1.x && $0.y < $1.y) })
            rbeams.sort(by: { $0.x < $1.x || ($0.x >= $1.x && $0.y < $1.y) })
            
            rmirrors = tiltToNorth(rmirrors, rbeams, rows.count)
            (rmirrors, rbeams) = rotate(rmirrors, rbeams, rows.count)
            rmirrors.sort(by: { $0.x < $1.x || ($0.x >= $1.x && $0.y < $1.y) })
            rbeams.sort(by: { $0.x < $1.x || ($0.x >= $1.x && $0.y < $1.y) })
            
            rmirrors = tiltToNorth(rmirrors, rbeams, rows[0].count)
            (rmirrors, rbeams) = rotate(rmirrors, rbeams, rows[0].count)
            rmirrors.sort(by: { $0.x < $1.x || ($0.x >= $1.x && $0.y < $1.y) })
            rbeams.sort(by: { $0.x < $1.x || ($0.x >= $1.x && $0.y < $1.y) })
            
            rmirrors = tiltToNorth(rmirrors, rbeams, rows.count)
            (rmirrors, rbeams) = rotate(rmirrors, rbeams, rows.count)
            rmirrors.sort(by: { $0.x < $1.x || ($0.x >= $1.x && $0.y < $1.y) })
            rbeams.sort(by: { $0.x < $1.x || ($0.x >= $1.x && $0.y < $1.y) })
       
            let same = Set(rmirrors) == Set(mirrors)
            mirrors = rmirrors
            if same {
                break
            }
            
            // spin converges to repetitive cycle
            // lets cheat by looking at values and taking
            // the one from (1000000000 - start) % len
            let l = load(mirrors, beams)
            print(l)
            spins -= 1
        }
    } else {
        mirrors = tiltToNorth(mirrors, beams, rows[0].count)
    }
    
    let l = load(mirrors, beams)
    return l
}

func totalLoadOnNorth(_ input: String) -> Int {
    assert(countLoadOnNorth("""
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
""", 0) == 136)
    return countLoadOnNorth(input, 0)
}

func totalLoadOnNorthWithSpins(_ input: String) -> Int {
    return countLoadOnNorth(input, 1000000000)
}
