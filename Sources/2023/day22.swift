private class Cube {
    var x: Int
    var y: Int
    var z: Int
    
    init(_ repr: String) {
        let comp = repr.components(separatedBy: ",")
        self.x = Int(comp[0])!
        self.y = Int(comp[1])!
        self.z = Int(comp[2])!
    }
}
 
extension Cube: Hashable, CustomStringConvertible, CustomDebugStringConvertible {
    static func == (lhs: Cube, rhs: Cube) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(z)
    }
    
    var debugDescription: String {
        description
    }
    
    var description: String {
        "\(x),\(y),\(z)"
    }
}

private class Brick {
    enum Coord {
        case x
        case y
        case z
    }
    
    var start: Cube
    var end: Cube
    var coord: Coord
    
    var x: ClosedRange<Int> {
        start.x...end.x
    }
    var y: ClosedRange<Int> {
        start.y...end.y
    }
    var z: ClosedRange<Int> {
        start.z...end.z
    }
    
    init(_ repr: String) {
        let comp = repr.components(separatedBy: "~")
        self.start = Cube(comp[0])
        self.end = Cube(comp[1])
        self.coord = if start.x == end.x && start.y == end.y {
            .z
        } else if start.x == end.x && start.z == end.z {
            .y
        } else {
            .x
        }
    }
    
    func collides(_ other: Brick, _ step: Int) -> Bool {
        switch (coord, other.coord) {
        case (.x, .x):
            return start.y == other.start.y && x.overlaps(other.x) && start.z + step == other.start.z
        case (.x, .y), (.y, .x):
            return x.overlaps(other.x) && y.overlaps(other.y) && start.z + step == other.start.z
        case (.x, .z):
            return x.overlaps(other.x) && y.overlaps(other.y) && start.z + step == other.start.z
        case (.z, .x):
            return x.overlaps(other.x) && y.overlaps(other.y) && end.z + step == other.start.z
        case (.y, .y):
            return start.x == other.start.x && y.overlaps(other.y) && start.z + step == other.start.z
        case (.y, .z):
            return x.overlaps(other.x) && y.overlaps(other.y) && start.z + step == other.start.z
        case (.z, .y):
            return x.overlaps(other.x) && y.overlaps(other.y) && end.z + step == other.start.z
        case (.z, .z):
            return start.x == other.start.x && start.y == other.start.y && end.z + step == other.start.z
        }
    }
    
    func pushdown(_ dz: Int) {
        self.start.z -= dz
        self.end.z -= dz
    }
}

extension Brick: Hashable, CustomStringConvertible, CustomDebugStringConvertible {
    static func == (lhs: Brick, rhs: Brick) -> Bool {
        lhs.start == rhs.start && lhs.end == rhs.end
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(start)
        hasher.combine(end)
    }
    
    var debugDescription: String {
        description
    }
    
    var description: String {
        "\(start)~\(end)"
    }
}

private func reduceState(_ input: String) -> ([Int: Set<Brick>], [Brick: Set<Brick>], [Brick: Set<Brick>]) {
    var leveledBricks: [Int: Set<Brick>] = input
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: "\n")
        .map(Brick.init(_:))
        .sorted(by: { $0.start.z < $1.start.z })
        .reduce(into: [:], { $0[$1.start.z, default: Set<Brick>()].insert($1) })
    
    var verticals: [Int: Set<Brick>] = leveledBricks.values
        .reduce(into: Set(), { $0.formUnion($1) })
        .filter({ $0.coord == .z })
        .reduce(into: [:], { $0[$1.end.z, default: []].insert($1) })
    
    leveledBricks[1] = leveledBricks[1, default: []]
    for i in 2...leveledBricks.keys.max()! {
        var queue = leveledBricks[i, default: []]
        while !queue.isEmpty {
            let brick = queue.removeFirst()
    
            var block: Brick? = nil
            var belowIdx = i - 1
            while belowIdx >= 1 {
                let vbelow = verticals[belowIdx, default: []]
                let below = leveledBricks[belowIdx, default: []]
                block = vbelow.union(below).first(where: {
                    $0.collides(brick, i - belowIdx)
                })
                if block != nil {
                    break
                }
                belowIdx -= 1
            }
            
            let pushdown = block != nil ? i - block!.end.z - 1 : brick.start.z - 1
            let newpos = block != nil ? block!.end.z + 1 : 1
            leveledBricks[i]?.remove(brick)
            brick.pushdown(pushdown)
            leveledBricks[newpos, default: []].insert(brick)
            verticals[brick.end.z + pushdown]?.remove(brick)
            verticals[brick.end.z, default: []].insert(brick)
        }
    }
    
    var supports: [Brick: Set<Brick>] = [:]
    for level in 1...leveledBricks.keys.max()! {
        let bricks = leveledBricks[level, default: []]
        
        for brick in bricks {
            if level == 1 {
                supports[brick] = []
                continue
            }
            
            var belowIdx = level - 1
            var c: Set<Brick> = []
            while belowIdx >= 1 {
                let below = leveledBricks[belowIdx, default: []]
                if belowIdx == level - 1 {
                    let base = below.filter({ $0.collides(brick, level - belowIdx) })
                    c.formUnion(base)
                } else {
                    let base = below.filter({ $0.end.z == level - 1 }).filter({ $0.collides(brick, 1) })
                    c.formUnion(base)
                }
                belowIdx -= 1
            }
            supports[brick] = c
        }
    }
    
    var reversed: [Brick: Set<Brick>] = [:]
    for (brick, support) in supports {
        if support.isEmpty {
            continue
        }
        support.forEach({ reversed[$0, default: []].insert(brick) })
    }
    
    var candidates: Set<Brick> = []
    for (brick, above) in reversed {
        if above.map({ supports[$0]!.count > 1 }).allSatisfy({ $0 }) {
            candidates.insert(brick)
        }
    }
    
    return (leveledBricks, supports, reversed)
}

private func solutionPt1(_ input: String) -> Int {
    let (_, supports, reversed) = reduceState(input)
    
    var candidates: Set<Brick> = []
    for (brick, above) in reversed {
        if above.map({ supports[$0]!.count > 1 }).allSatisfy({ $0 }) {
            candidates.insert(brick)
        }
    }
    
    let top = supports.count - reversed.count
    let res = candidates.count + top
    return res
}


private func solutionPt2(_ input: String) -> Int {
    let (leveledBricks, supports, reversed) = reduceState(input)
    
    var total = 0
    for brick in leveledBricks.values.reduce(into: Set(), { $0.formUnion($1) }) {
        var destroyed: Set<Brick> = [brick]
        var queue = reversed[brick, default: []]
        while !queue.isEmpty {
            let b = queue.removeFirst()
            let support = supports[b, default: []]
            if support.subtracting(destroyed).count == 0 {
                total += 1
                destroyed.insert(b)
                queue.formUnion(reversed[b, default: []])
            }
        }
    }
    return total
}

func countDisintegrationCandidates(_ input: String) -> Int {
    assert(solutionPt1("""
0,0,1~0,0,3
1,0,1~1,0,1
2,0,1~2,0,1
2,0,2~3,0,2
3,3,5~3,3,9
""") == 4)
    assert(solutionPt1("""
0,0,1~0,0,3
0,0,4~0,0,5
""") == 1)
    assert(solutionPt1("""
1,0,1~1,2,1
0,0,2~2,0,2
0,2,3~2,2,3
0,0,4~0,2,4
2,0,5~2,2,5
0,1,6~2,1,6
1,1,8~1,1,9
""") == 5)
    return solutionPt1(input)
}

func totalBrickToCollaps(_ input: String) -> Int {
    assert(solutionPt2("""
1,0,1~1,2,1
0,0,2~2,0,2
0,2,3~2,2,3
0,0,4~0,2,4
2,0,5~2,2,5
0,1,6~2,1,6
1,1,8~1,1,9
""") == 7)
    return solutionPt2(input)
}
