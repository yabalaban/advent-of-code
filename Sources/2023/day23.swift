private enum Direction {
    case left
    case right
    case up
    case down
}

private func solutionPt1(_ input: String) -> Int {
    func neighbours(_ lines: [String], _ p: Point) -> [(Point, Direction, Character)] {
        let possible: [(Point, Direction)] = [
            (Point(p.x - 1, p.y), .left),
            (Point(p.x + 1, p.y), .right),
            (Point(p.x, p.y - 1), .up),
            (Point(p.x, p.y + 1), .down),
        ].filter({ $0.0.x >= 0 && $0.0.x < lines.first!.count && $0.0.y >= 0 && $0.0.y < lines.count })
        return possible.map({ (p, d) in
            let row = lines[p.y]
            return (p, d, row[row.index(row.startIndex, offsetBy: p.x)])
        })
    }
    
    let lines = input.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
    let start = Point(lines.first!.firstIndex(of: ".")!.utf16Offset(in: lines.first!), 0)
    let end = Point(lines.last!.firstIndex(of: ".")!.utf16Offset(in: lines.last!), lines.count - 1)
                 
    var queue: [(Point, Int, Set<Point>)] = [(start, 0, [])]
    var maxSteps = -1
    
    while !queue.isEmpty {
        var (node, steps, visited) = queue.removeFirst()
        if node == end {
            maxSteps = max(maxSteps, steps)
        }
        visited.insert(node)
        let neigh = neighbours(lines, node)
        for (p, d, ch) in neigh {
            if visited.contains(p) {
                continue
            }
            
            switch ch {
            case "#":
                continue
            case ".":
                queue.append((p, steps + 1, visited))
            case ">":
                if d == .right {
                    queue.append((p, steps + 1, visited))
                }
            case "<":
                if d == .left {
                    queue.append((p, steps + 1, visited))
                }
            case "^":
                if d == .up {
                    queue.append((p, steps + 1, visited))
                }
            case "v":
                if d == .down {
                    queue.append((p, steps + 1, visited))
                }
            default:
                fatalError()
            }
        }
    }
    
    return maxSteps
}

extension Point {
    fileprivate func move(_ d: Direction) -> Point {
        switch d {
        case .down:
            return Point(x, y - 1)
        case .up:
            return Point(x, y + 1)
        case .left:
            return Point(x + 1, y)
        case .right:
            return Point(x - 1, y)
        }
    }
}

private struct Warp: Hashable {
    let node: Point
    let direction: Direction
}

private func solutionPt2(_ input: String) -> Int {
    func neighbours(_ lines: [String], _ p: Point) -> [Point] {
        let around: [Point] = [
            Point(p.x - 1, p.y),
            Point(p.x + 1, p.y),
            Point(p.x, p.y - 1),
            Point(p.x, p.y + 1),
        ]
        return around
            .filter({ $0.x >= 0 && $0.x < lines.first!.count && $0.y >= 0 && $0.y < lines.count })
            .compactMap({ p in
                let row = lines[p.y]
                let ch = row[row.index(row.startIndex, offsetBy: p.x)]
                return [".", ">", "<", "v", "^"].contains(ch) ? p : nil
            })
    }
    
    let lines = input.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
    let start = Point(lines.first!.firstIndex(of: ".")!.utf16Offset(in: lines.first!), 0)
    let end = Point(lines.last!.firstIndex(of: ".")!.utf16Offset(in: lines.last!), lines.count - 1)
    
    var knots: [Point: [(Point, Int)]] = [:]
    for (y, line) in lines.enumerated() {
        for (x, ch) in line.enumerated() {
            guard ch != "#" else { continue }
            let node = Point(x, y)
            let neigh = neighbours(lines, node)
            if neigh.count > 2 {
                knots[node] = []
            }
        }
    }
    knots[start] = []
    knots[end] = []
    
    for knot in knots.keys {
        var queue: [(Point, Int)] = [(knot, 0)]
        var visited: Set<Point> = []
        
        while !queue.isEmpty {
            let (node, steps) = queue.removeFirst()
            guard !visited.contains(node) else { continue }
            
            visited.insert(node)
            if knots[node] != nil && knot != node {
                knots[knot, default: []].append((node, steps))
                continue
            }
            
            let neigh = neighbours(lines, node)
            for n in neigh {
                queue.append((n, steps + 1))
            }
        }
    }
    
    var maxSteps = 0
    var visited: Set<Point> = []
    func dfs(_ node: Point, _ steps: Int) {
        guard !visited.contains(node) else { return }
        if node == end {
            maxSteps = max(maxSteps, steps)
            return
        }
        
        visited.insert(node)
        let neigh = knots[node]!
        for (n, s) in neigh {
            dfs(n, steps + s)
        }
        visited.remove(node)
    }
    
    return maxSteps
}

func stepsOfLongestHike(_ input: String) -> Int {
    assert(solutionPt1("""
#.#####################
#.......#########...###
#######.#########.#.###
###.....#.>.>.###.#.###
###v#####.#v#.###.#.###
###.>...#.#.#.....#...#
###v###.#.#.#########.#
###...#.#.#.......#...#
#####.#.#.#######.#.###
#.....#.#.#.......#...#
#.#####.#.#.#########v#
#.#...#...#...###...>.#
#.#.#v#######v###.###v#
#...#.>.#...>.>.#.###.#
#####v#.#.###v#.#.###.#
#.....#...#...#.#.#...#
#.#########.###.#.#.###
#...###...#...#...#.###
###.###.#.###v#####v###
#...#...#.#.>.>.#.>.###
#.###.###.#.###.#.#v###
#.....###...###...#...#
#####################.#
""") == 94)
    return solutionPt1(input)
}
                 
 func stepsOfLongestHikeExtended(_ input: String) -> Int {
//     assert(solutionPt2("""
// #.#
// #.#
// """) == 1)
//     assert(solutionPt2("""
// #.##
// #..#
// #..#
// ##.#
// """) == 4)
//     assert(solutionPt2("""
// #.####
// #.####
// #....#
// #.##.#
// #.#..#
// #...##
// ###.##
// """) == 10)
//     assert(solutionPt2("""
// #.###########
// #.#.....#...#
// #.#.###.#.#.#
// #.#.#...#.#.#
// #.#.#.###.#.#
// #...#.....#.#
// ###########.#
// """) == 36)
//     assert(solutionPt2("""
// #.#####################
// #.......#########...###
// #######.#########.#.###
// ###.....#.>.>.###.#.###
// ###v#####.#v#.###.#.###
// ###.>...#.#.#.....#...#
// ###v###.#.#.#########.#
// ###...#.#.#.......#...#
// #####.#.#.#######.#.###
// #.....#.#.#.......#...#
// #.#####.#.#.#########v#
// #.#...#...#...###...>.#
// #.#.#v#######v###.###v#
// #...#.>.#...>.>.#.###.#
// #####v#.#.###v#.#.###.#
// #.....#...#...#.#.#...#
// #.#########.###.#.#.###
// #...###...#...#...#.###
// ###.###.#.###v#####v###
// #...#...#.#.>.>.#.>.###
// #.###.###.#.###.#.#v###
// #.....###...###...#...#
// #####################.#
// """) == 154)
     // 6328 too low
     // 5190 too low
     // 6747 not right
     // 6574 is correct
     return solutionPt2(input)
 }
