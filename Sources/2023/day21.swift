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

private struct Patch: Hashable, CustomDebugStringConvertible {
    var origin: Point
    var points: Set<Point>
    
    var debugDescription: String {
        "\(origin): \(points)"
    }
    
    func offset(_ p: Point, _ rlen: Int, _ clen: Int) -> Patch {
        Patch(origin: Point(origin.x + p.x, origin.y + p.y), points: points)
    }
}

private func solution2(_ input: String, _ steps: Int) -> Int {
    var cache: [Point: [Patch]] = [:]
    var cpatches: [Patch: Patch] = [:]
    
    func neighbours(_ p: Point, _ origin: Point) -> [Patch] {
        var x = p.x % lines[0].count
        var y = p.y % lines.count
        let dx = p.x / lines[0].count + (x < 0 ? -1 : 0)
        let dy = p.y / lines.count + (y < 0 ? -1 : 0)
        x = x < 0 ? lines[0].count + x : x
        y = y < 0 ? lines.count + y : y
        
        let np = Point(x, y)
        if let cached = cache[np] {
            let c = cached.map({ $0.offset(Point(origin.x + dx, origin.y + dy), lines[0].count, lines.count) })
            return c
        }
        
        let p = np
        let candidates = [
            Point(p.x - 1, p.y),
            Point(p.x + 1, p.y),
            Point(p.x, p.y - 1),
            Point(p.x, p.y + 1)
        ]
        let points = Set(
            candidates
                .filter({ cand in !stones.contains(where: { stone in
                    var x = cand.x % lines[0].count
                    var y = cand.y % lines.count
                    x = x < 0 ? lines[0].count + x : x
                    y = y < 0 ? lines.count + y : y
                    return stone == Point(x, y) })
                })
        )
        let xs = points.reduce(into: [:]) { acc, p in acc[p.x / lines[0].count + (p.x < 0 ? -1 : 0), default: []].append(p) }
        let ys = points.reduce(into: [:]) { acc, p in acc[p.y / lines.count + (p.y < 0 ? -1 : 0), default: []].append(p) }
        let rys = ys.reduce(into: [:], { acc, ps in ps.value.forEach({ acc[$0] = ps.key }) })
        
        var pairs: [Point: [Point]] = [:]
        for p in xs {
            let (x, points) = p
            for point in points {
                let y = rys[point]!
                var nx = point.x % lines[0].count
                var ny = point.y % lines.count
                nx = nx < 0 ? lines[0].count + nx : nx
                ny = ny < 0 ? lines.count + ny : ny
                pairs[Point(x, y), default: []].append(Point(nx, ny))
            }
        }
        
        let res = pairs.map({ Patch(origin: $0.key, points: Set($0.value)) })
        cache[p] = res
        return res.map({ $0.offset(Point(origin.x + dx, origin.y + dy), lines[0].count, lines.count) })
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
    
    var patches: [Patch] = [Patch(origin: Point(0, 0), points: [start[0]])]
    
    for i in 0..<steps {
        if i % 10 == 0 {
            print(i)
        }
        var pmap: [Point: Patch] = [:]
        for patch in patches {
            if let cached = cpatches[patch] {
                pmap[patch.origin] = cached
                continue
            }
            
            var lpmap: [Point: Patch] = [:]
            for plot in patch.points {
                let npatches = neighbours(plot, patch.origin)
                for npatch in npatches {
                    if lpmap[npatch.origin] != nil {
                        lpmap[npatch.origin]?.points.formUnion(npatch.points)
                    } else {
                        lpmap[npatch.origin] = npatch
                    }
                }
            }
            
            cpatches[patch] = lpmap[patch.origin]!
            for (origin, p) in lpmap {
                if pmap[origin] != nil {
                    pmap[origin]?.points.formUnion(p.points)
                } else {
                    pmap[origin] = p
                }
            }
        }
        
        patches = Array(pmap.values)
    }
    
    var res = 0
    for patch in patches {
        res += patch.points.count
    }
    return res
}


private func solution3(_ input: String, _ steps: Int) -> Int {
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
    
    let stones = lines.enumerated()
        .map({ (y, line) in line
                .enumerated()
                .filter({ $0.element == "#" })
                .map({ ($0.offset, y) })
        })
        .reduce(into: [], { $0.append(contentsOf: $1) })
        .map({ Point($0.0 - starts[0].x, $0.1 - starts[0].y) })
    
    func hm(_ p: Point) -> Point? {
        if p.x == 0 {
            if p.y > 0 {
                if stones.contains(Point(p.x, p.y - 1)) {
                    return nil
                } else {
                    return p
                }
            } else if p.y < 0 {
                if stones.contains(Point(p.x, p.y + 1)) {
                    return nil
                } else {
                    return p
                }
            } else {
                return p
            }
        } else if p.x > 0 {
            if p.y == 0 {
                if stones.contains(Point(p.x - 1, p.y)) {
                    return nil
                } else {
                    return p
                }
            } else if p.y > 0 {
                if stones.contains(Point(p.x - 1, p.y - 1)) {
//                    if stones.contains(Point(p.x - 1, p.y - 1)) || stones.contains(Point(p.x - 1, p.y)) || stones.contains(Point(p.x, p.y - 1)) {
                    return nil
                } else {
                    return p
                }
            } else {
                if stones.contains(Point(p.x - 1, p.y + 1)) {
//                    if stones.contains(Point(p.x - 1, p.y + 1)) || stones.contains(Point(p.x - 1, p.y)) || stones.contains(Point(p.x, p.y + 1)) {
                    return nil
                } else {
                    return p
                }
            }
        } else {
            if p.y == 0 {
                if stones.contains(Point(p.x + 1, p.y)) {
                    return nil
                } else {
                    return p
                }
            } else if p.y > 0 {
                if stones.contains(Point(p.x + 1, p.y - 1)) {
//                    if stones.contains(Point(p.x + 1, p.y - 1)) || stones.contains(Point(p.x + 1, p.y)) || stones.contains(Point(p.x, p.y - 1))  {
                    return nil
                } else {
                    return p
                }
            } else {
                if stones.contains(Point(p.x + 1, p.y + 1)) {
//                    if stones.contains(Point(p.x + 1, p.y + 1)) || stones.contains(Point(p.x + 1, p.y)) || stones.contains(Point(p.x, p.y + 1)) {
                    return nil
                } else {
                    return p
                }
            }
        }
    }
    
    var points = Set<Point>()
    var steps = steps
    while steps >= 0 {
        for i in 0...steps {
            if let p = hm(Point(steps - i, i)) {
                points.insert(p)
            }
            if let p = hm(Point(steps - i, -i)) {
                points.insert(p)
            }
            if let p = hm(Point(i - steps, i)) {
                points.insert(p)
            }
            if let p = hm(Point(i - steps, -i)) {
                points.insert(p)
            }
        }
        steps -= 2
    }
    
    let res = points.subtracting(stones).count - 1
    return res
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
    
    let diff = steps - rlen * whole
    for i in 0..<diff {
        var edge = 0
        var points: Set<Point> = []
        for x in 0...i {
            points.formUnion([
                Point((i - x) % rlen, x % clen),
                Point((i - x) % rlen, -x % clen),
                Point((x - i) % rlen, x % clen),
                Point((x - i) % rlen, -x % clen),
            ])
        }
        Set(points).forEach { p in
            if stones.contains(p) {
                edge += 1
            }
        }
        cstones += edge
    }
    
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
    assert(solution2("""
...........
.....%##.#.
.###.%%..#.
..#.%...#..
....%.%....
.%%..S%%%%.
.#%..%...#.
.......%#..
.##.%.%###.
.##..%#.##.
...........
""", 6) == 16)
    assert(solution2("""
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
""", 10) == 50)
    assert(solution2("""
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
""", 50) == 1594)
    assert(solution3("""
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
""", 100) == 6536)
    assert(solution3("""
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
""", 500) == 167004)
    assert(solution3("""
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
""", 1000) == 668697)
    assert(solution3("""
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
""", 5000) == 16733044)
    // 702316425012755 too high
    // 102436503376435 too low
    return solution3(input, 26501365)
}
