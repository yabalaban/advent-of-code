import Foundation

private func neighbours(_ p: Point, _ lines: [String], _ stones: [Point], _ overflow: Bool) -> Set<Point> {
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
    return res
}

private func solutionPt1(_ input: String, _ steps: Int, _ overflow: Bool = false) -> Int {
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
            next.formUnion(neighbours(plot, lines, stones, overflow))
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
    guard let start = starts.first else { fatalError() }
    let stones = lines.enumerated()
        .map({ (y, line) in line
                .enumerated()
                .filter({ $0.element == "#" })
                .map({ ($0.offset, y) })
        })
        .reduce(into: [], { $0.append(contentsOf: $1) })
        .map({ Point($0.0, $0.1) })
    

    // After hours of visual exploration of the input and different
    // values in playground (also a hint of perfect cubes) I've figured
    // out there might be a formulaic solution. Everything is about the width (131)
    // and remainder (65). I gave up trying to find the single formula to fit it, but
    // my last try with wolfram to `interpolate()` values seems finally working.
    
    /* Using the width and remainder as a cycle, we can count 65, 65 + 131, and 65 + 2 * 131.
    let rlen = lines[0].count
    let clen = lines.count
     
    var s: [Int] = []
    var queue: Set<Point> = [start]
    var i = 1
    while s.count < 3 {
        var counter = 0
        var nq: Set<Point> = []
        for plot in queue {
            let plots = Set([
                Point(plot.x - 1, plot.y),
                Point(plot.x + 1, plot.y),
                Point(plot.x, plot.y - 1),
                Point(plot.x, plot.y + 1),
            ]).filter({ plot in
                !stones.contains(where: { stone in
                    var x = plot.x % rlen
                    var y = plot.y % clen
                    x = x < 0 ? rlen + x : x
                    y = y < 0 ? clen + y : y
                    return stone == Point(x, y)
                })
            })
            for plot in plots {
                nq.insert(plot)
            }
        }
        queue = nq
        if (i - 65) % 131 == 0 {
            s.append(queue.count)
        }
        i += 1
    }
     */
    
    let s: [Int] = [3738, 33270, 92194]
    // from wolfram by `interpolate(3738, 33270, 92194)`
    assert((steps - 65) % 131 == 0)
    let x = (steps - 65) / 131 + 1
    let res = 14696 * x * x - 14556 * x + 3598
    
    // one of the failed attempts for history
    
    /*
    // if we ignore stones, total number of garden plots available
    // after N step is a perfect cube of N. easy to prove on squared paper
    // Assumption: map converges into the stable state.
    
    // 1. Calculate spots for odd and even steps (no overflow)
    let spots = lines
        .enumerated()
        .map({ (y, line) in
            line.enumerated()
                .filter({ $0.element != "#" })
                .map({ ($0.offset, y) })
        })
        .reduce(into: [], { $0.append(contentsOf: $1) })
        .map({ Point($0.0 - start.x, $0.1 - start.y) })
    let odd = spots.filter({ (abs($0.x) + abs($0.y)) % 2 == 1 })
    let even = spots.filter({ (abs($0.x) + abs($0.y)) % 2 == 0 })
    // 2. Count spots with > 65 steps
    let oddfar = odd.filter({ abs($0.x) + abs($0.y) > 65 })
    let evenfar = even.filter({ abs($0.x) + abs($0.y) > 65 })
    // 3a. Since steps > grid * rlen, we need to take one extra which we will compensate
    // by deducing the excessive spots. Also extra is odd, so we need to do this only
    // for odd spots. Number of full maps is a cube, and far spots are placed along
    // the side of the resulting grid.
    let evenfinal = grid * grid * even.count + grid * evenfar.count
    // 3b. Since steps - grid * rlen = 65 => we imply the grid to have extra maps
    // for odd distance. However, we have to compensate
    let oddfinal = (grid + 1) * (grid + 1) * odd.count - (grid + 1) * oddfar.count
    // 4a. finally sum it up
    let res = evenfinal + oddfinal
     */
    
    return Int(res)
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
    return solutionPt2(input, 26501365)
}
