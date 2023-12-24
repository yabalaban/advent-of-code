import Foundation

private func solutionPt1(_ input: String, _ steps: Int, _ overflow: Bool = false) -> Int {
    var cache: [Point: Set<Point>] = [:]
    
    func neighbours(_ p: Point, _ overflow: Bool) -> Set<Point> {
        if let cached = cache[p] {
            return cached
        }
        let candidates = [
            Point(p.x - 1, p.y),
            Point(p.x + 1, p.y),
            Point(p.x, p.y - 1),
            Point(p.x, p.y + 1)
        ]
        let res: Set<Point>
        if overflow {
            res = Set(
                candidates
                    .filter({ cand in !stones.contains(where: { stone in
                        var x = cand.x % lines[0].count
                        var y = cand.y % lines.count
                        x = x < 0 ? lines[0].count + x : x
                        y = y < 0 ? lines.count + y : y
                        return stone == Point(x, y) })
                    })
            )
        } else {
            res = Set(
                candidates
                    .filter({ cand in cand.x >= 0 && cand.x < lines[0].count && cand.y >= 0 && cand.y < lines.count })
                    .filter({ cand in !stones.contains(where: { $0 == cand }) })
            )
        }
        cache[p] = res
        return res
    }
    
    let lines = input.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
    let stones = lines.enumerated()
        .map({ (y, line) in line
                .enumerated()
                .filter({ $0.element == "#" })
                .map({ ($0.offset, y) })
        })
        .reduce(into: [], { $0.append(contentsOf: $1) })
        .map({ Point($0.0, $0.1) })
    let start = lines.enumerated()
        .map({ (y, line) in line
                .enumerated()
                .filter({ $0.element == "S" })
                .map({ ($0.offset, y) })
        })
        .reduce(into: [], { $0.append(contentsOf: $1) })
        .map({ Point($0.0, $0.1) })
    assert(start.count == 1)
    
    var plots: Set<Point> = Set([start[0]])
    
    for _ in 0..<steps {
        var next = Set<Point>()
        for plot in plots {
            next.formUnion(neighbours(plot, overflow))
        }
        plots = next
    }
    
    return plots.count
}

private func solutionPt2(_ input: String, _ steps: Int) -> Int {
    let lines = input.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
    let starts = lines.enumerated()
        .map({ (y, line) in line
                .enumerated()
                .filter({ $0.element == "S" })
                .map({ ($0.offset, y) })
        })
        .reduce(into: [], { $0.append(contentsOf: $1) })
        .map({ Point($0.0, $0.1) })
    assert(starts.count == 1)
    let rlen = lines[0].count
    let clen = lines.count
    
    let stones = lines.enumerated()
        .map({ (y, line) in line
                .enumerated()
                .filter({ $0.element == "#" })
                .map({ ($0.offset, y) })
        })
        .reduce(into: [], { $0.append(contentsOf: $1) })
        .map({ Point($0.0 - starts[0].x, $0.1 - starts[0].y) })
    
    assert(rlen == clen)
    
    let whole = Int(floor(Double(steps) / Double(rlen)))
    var cstones = stones.count * 2 * whole * whole
    
//    (whole + 1) * (whole + 1) * x
//    whole * whole * x
//    (whole + 1) * x
//    whole * x
    return steps * steps - cstones
}


func countGardenPlots(_ input: String) -> Int {
    assert(solutionPt1("""
...........
.....#.....
...#.##....
..#.#......
....#.#....
.##..S####.
.##..#...#.
.......##..
....#.##...
.....##....
...........
""", 2) == 4)
    assert(solutionPt1("""
...........
.....###.#.
.###.##..#.
..#.#...#..
....#.#....
.##..S####.
.##..#...#.
.......##..
.##.#.####.
.##..##.##.
...........
""", 6) == 16)
    return solutionPt1(input, 64)
}

func countGardenPlotsInfinitely(_ input: String) -> Int {
    // 702316425012755 too high
    // 102436503376435 too low
    return solutionPt2(input, 26501365)
}
