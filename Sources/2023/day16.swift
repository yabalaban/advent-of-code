private class Beam: CustomStringConvertible {
    struct Reflection: Hashable {
        let mirror: Point
        let direction: Direction
        
        init(_ mirror: Point, _ direction: Direction) {
            self.mirror = mirror
            self.direction = direction
        }
    }
    
    enum Direction: String {
        case up
        case down
        case left
        case right
    }
    
    var coord: Point = Point(0, 0)
    var direction: Direction = .right
    var reflections: Set<Reflection> = []
    
    var vertical: Bool {
        [.up, .down].contains(direction)
    }
    
    func turn(_ direction: Direction, _ d: Point) -> Beam {
        let b = Beam()
        b.direction = direction
        b.coord = d
        b.reflections = reflections
        return b
    }
    
    var description: String {
        "\(coord) \(direction.rawValue)"
    }
}

private func traceBeams(_ input: String, _ start: [Beam]) -> Int {
    var reflections: Set<Beam.Reflection> = []
    
    func move(_ beam: Beam, _ rdir: Beam.Direction, _ coord: Int) -> (Beam, Bool) {
        let point = beam.vertical ? Point(beam.coord.x, coord) : Point(coord, beam.coord.y)
        let reflection = Beam.Reflection(point, rdir)
        let nbeam = beam.turn(rdir, point)
        let cycle = reflections.contains(reflection)
        reflections.insert(reflection)
        return (nbeam, cycle)
    }
    
    func path(_ p1: Point, _ p2: Point) -> [Point] {
        let x1 = min(p1.x, p2.x)
        let x2 = max(p1.x, p2.x)
        let y1 = min(p1.y, p2.y)
        let y2 = max(p1.y, p2.y)
        var path = [Point]()
        for x in x1...x2 {
            for y in y1...y2 {
                path.append(Point(x, y))
            }
        }
        return path
    }
    
    let lines = input.components(separatedBy: "\n")
        .filter({ !$0.isEmpty })
    let mirrors: [Int: [Int: String]] = lines
        .enumerated()
        .reduce(into: [:], { (acc, row) in
            let (y, line) = row
            line.enumerated().forEach { (x, ch) in
                if ["|", "-", "/", "\\"].contains(ch) {
                    acc[y, default: [:]][x] = String(ch)
                }
            }
        })
    
    var queue = start
    var marked: Set<Point> = []
    
    while queue.count > 0 {
        let beam = queue.removeFirst()
        guard (0..<lines[0].count).contains(beam.coord.x) else { continue }
        guard (0..<lines.count).contains(beam.coord.y) else { continue }
        
        let candidates: [Int: String] = if !beam.vertical {
            mirrors[beam.coord.y, default: [:]]
        } else {
            mirrors.keys.reduce(into: [:], { (acc, key) in
                if let mirror = mirrors[key]?[beam.coord.x] {
                    acc[key] = mirror
                }
            })
        }
        
        let candidate = switch beam.direction {
        case .right:
            candidates.sorted(by: { $0.key < $1.key }).first(where: { $0.key > beam.coord.x })
        case .left:
            candidates.sorted(by: { $0.key > $1.key }).first(where: { $0.key < beam.coord.x })
        case .down:
            candidates.sorted(by: { $0.key < $1.key }).first(where: { $0.key > beam.coord.y })
        case .up:
            candidates.sorted(by: { $0.key > $1.key }).first(where: { $0.key < beam.coord.y })
        }
        guard let candidate else { 
            let external = switch beam.direction {
            case .up:
                Point(beam.coord.x, 0)
            case .down:
                Point(beam.coord.x, lines.count - 1)
            case .left:
                Point(0, beam.coord.y)
            case .right:
                Point(lines[0].count - 1, beam.coord.y)
            }
            marked = marked.union(path(beam.coord, external))
            continue
        }
        
        switch candidate.value {
        case "|":
            let rdirs: [Beam.Direction] = switch beam.direction {
            case .left, .right:
                [.up, .down]
            case .up:
                [.up]
            case .down:
                [.down]
            }
            rdirs.compactMap({ move(beam, $0, candidate.key) })
                .forEach({
                    marked = marked.union(path(beam.coord, $0.0.coord))
                    if !$0.1 {
                        queue.append($0.0)
                    }
                })
        case "-":
            let rdirs: [Beam.Direction] = switch beam.direction {
            case .up, .down:
                [.left, .right]
            case .left:
                [.left]
            case .right:
                [.right]
            }
            rdirs.compactMap({ move(beam, $0, candidate.key) })
                .forEach({
                    marked = marked.union(path(beam.coord, $0.0.coord))
                    if !$0.1 {
                        queue.append($0.0)
                    }
                })
        case "\\":
            let rdir: Beam.Direction = switch beam.direction {
            case .up:
                .left
            case .down:
                .right
            case .left:
                .up
            case .right:
                .down
            }
            let (b, cycle) = move(beam, rdir, candidate.key)
            marked = marked.union(path(beam.coord, b.coord))
            if !cycle {
                queue.append(b)
            }
        case "/":
            let rdir: Beam.Direction = switch beam.direction {
            case .up:
                .right
            case .down:
                .left
            case .left:
                .down
            case .right:
                .up
            }
            let (b, cycle) = move(beam, rdir, candidate.key)
            marked = marked.union(path(beam.coord, b.coord))
            if !cycle {
                queue.append(b)
            }
        default:
            fatalError()
        }
    }
    
    return marked.count
}

func countEnergizedCells(_ input: String) -> Int {
    let beam = Beam()
    
    assert(traceBeams("""
.|...\\....
|.-.\\.....
.....|-...
........|.
..........
.........\\
..../.\\\\..
.-.-/..|..
.|....-|.\\
..//.|....
""", [beam]) == 46)
    assert(traceBeams("""
\\-\\
|-|
\\-/
""", [beam]) == 8)
    assert(traceBeams("""
...
""", [beam]) == 3)
    assert(traceBeams("""
\\..
...
...
""", [beam]) == 3)
    
    if input.first == "|" || input.first == "\\" {
        beam.direction = .down
    }
    return traceBeams(input, [beam])
}

func traceBeamsGridSearch(_ input: String) -> Int {
    let lines = input.components(separatedBy: "\n").filter({ !$0.isEmpty })
    var start: [[Beam]] = []
    
    for i in 0..<lines.count {
        switch lines[i].first {
        case "|":
            let b1 = Beam()
            b1.direction = .up
            b1.coord.y = i
            let b2 = Beam()
            b2.direction = .down
            b2.coord.y = i
            start.append([b1, b2])
        case "/":
            let beam = Beam()
            beam.direction = .up
            beam.coord.y = i
            start.append([beam])
        case "\\":
            let beam = Beam()
            beam.direction = .down
            beam.coord.y = i
            start.append([beam])
        default:
            let beam = Beam()
            beam.coord.y = i
            start.append([beam])
        }
        
        switch lines[i].last {
        case "|":
            let b1 = Beam()
            b1.direction = .up
            b1.coord.y = i
            b1.coord.x = lines[0].count - 1
            let b2 = Beam()
            b2.direction = .down
            b2.coord.y = i
            b2.coord.x = lines[0].count - 1
            start.append([b1, b2])
        case "/":
            let beam = Beam()
            beam.direction = .down
            beam.coord.y = i
            beam.coord.x = lines[0].count - 1
            start.append([beam])
        case "\\":
            let beam = Beam()
            beam.direction = .up
            beam.coord.y = i
            beam.coord.x = lines[0].count - 1
            start.append([beam])
        default:
            let beam = Beam()
            beam.direction = .left
            beam.coord.y = i
            beam.coord.x = lines[0].count - 1
            start.append([beam])
        }
    }
    
    for i in 0..<lines.first!.count {
        let top = lines.first!
        let bottom = lines.last!
        switch top[top.index(top.startIndex, offsetBy: i)] {
        case "-":
            let b1 = Beam()
            b1.direction = .left
            b1.coord.x = i
            let b2 = Beam()
            b2.direction = .right
            b2.coord.x = i
            start.append([b1, b2])
        case "/":
            let beam = Beam()
            beam.direction = .left
            beam.coord.x = i
            start.append([beam])
        case "\\":
            let beam = Beam()
            beam.direction = .right
            beam.coord.x = i
            start.append([beam])
        default:
            let beam = Beam()
            beam.direction = .down
            beam.coord.x = i
            start.append([beam])
        }
        
        switch bottom[bottom.index(bottom.startIndex, offsetBy: i)] {
        case "-":
            let b1 = Beam()
            b1.direction = .left
            b1.coord.x = i
            b1.coord.y = lines.count - 1
            let b2 = Beam()
            b2.direction = .right
            b2.coord.x = i
            b2.coord.y = lines.count - 1
            start.append([b1, b2])
        case "/":
            let beam = Beam()
            beam.direction = .right
            beam.coord.x = i
            beam.coord.y = lines.count - 1
            start.append([beam])
        case "\\":
            let beam = Beam()
            beam.direction = .left
            beam.coord.x = i
            beam.coord.y = lines.count - 1
            start.append([beam])
        default:
            let beam = Beam()
            beam.direction = .up
            beam.coord.x = i
            beam.coord.y = lines.count - 1
            start.append([beam])
        }
    }
    
    return start.map({ traceBeams(input, $0) }).max()!
}

func countEnergizedCellsGridSearch(_ input: String) -> Int {
    assert(traceBeamsGridSearch("""
.|...\\....
|.-.\\.....
.....|-...
........|.
..........
.........\\
..../.\\\\..
.-.-/..|..
.|....-|.\\
..//.|....
""") == 51)
    return traceBeamsGridSearch(input)
}

// 8358
