import Collections

private struct Coord: Hashable {
    let x: Int
    let y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
}

private enum Move: Hashable {
    case start
    case left(Int)
    case right(Int)
    case up(Int)
    case down(Int)
    
    func next(_ m: Move, _ min: Int, _ max: Int) -> Move? {
        switch m {
        case .left:
            switch self {
            case .left(let c):
                if c < min {
                    return .left(c + 1)
                }
                return c + 1 <= max ? .left(c + 1) : nil
            case .right:
                return nil
            case .down(let c):
                return c >= min ? .left(1) : nil
            case .up(let c):
                return c >= min ? .left(1) : nil
            case .start:
                return .left(1)
            }
        case .right:
            switch self {
            case .right(let c):
                return c + 1 <= max ? .right(c + 1) : nil
            case .left:
                return nil
            case .down(let c):
                return c >= min ? .right(1) : nil
            case .up(let c):
                return c >= min ? .right(1) : nil
            case .start:
                return .right(1)
            }
        case .up:
            switch self {
            case .up(let c):
                return c + 1 <= max ? .up(c + 1) : nil
            case .down:
                return nil
            case .left(let c):
                return c >= min ? .up(1) : nil
            case .right(let c):
                return c >= min ? .up(1) : nil
            case .start:
                return .up(1)
            }
        case .down:
            switch self {
            case .down(let c):
                return c + 1 <= max ? .down(c + 1) : nil
            case .up:
                return nil
            case .left(let c):
                return c >= min ? .down(1) : nil
            case .right(let c):
                return c >= min ? .down(1) : nil
            case .start:
                return .down(1)
            }
        case .start:
            return m
        }
    }
}

private func heatloss(_ coord: Coord, _ lines: [String]) -> Int {
    let row = lines[coord.y]
    return row[row.index(row.startIndex, offsetBy: coord.x)].wholeNumberValue!
}

private struct Pair<P1: Hashable, P2: Hashable>: Hashable {
    let p1: P1
    let p2: P2
    
    init(_ p1: P1, _ p2: P2) {
        self.p1 = p1
        self.p2 = p2
    }
}

private func solution(_ input: String, _ min: Int = 0, _ max: Int = 3) -> Int {
    func appendIfNeeded(_ ncoord: Coord, _ nmove: Move, _ thl: Int) {
        let nthl = state[ncoord, default: [:]][nmove, default: 1000000000]
        let nhl = heatloss(ncoord, lines)
        if nthl > thl + nhl {
            let ex = queue[Pair(ncoord, nmove), default: 1000000000]
            if thl < ex  {
                queue[Pair(ncoord, nmove)] = thl
            }
        }
    }
    
    let lines = input.components(separatedBy: "\n").filter({ !$0.isEmpty })
    let clen = lines.count
    let rlen = lines[0].count
    
    let start = Coord(0, 0)
    let end = Coord(rlen - 1, clen - 1)
    
    var state: [Coord: [Move: Int]] = [:]
    var queue: OrderedDictionary<Pair<Coord, Move>, Int> = [Pair(start, .start): 0]
    
    while !queue.isEmpty {
        let pair = queue.keys.first!
        let (coord, move) = (pair.p1, pair.p2)
        let score = queue.removeValue(forKey: pair)!
        
        let hl = heatloss(coord, lines)
        let thl = score + hl
        if (state[coord]?[move] ?? 1000000000) < thl {
            continue
        } else {
            state[coord, default: [:]][move] = thl
        }
        
        let moves = [
            move.next(.right(1), min, max),
            move.next(.down(1), min, max),
            move.next(.left(1), min, max),
            move.next(.up(1), min, max)
        ].compactMap({ $0 })
        
        for nmove in moves {
            switch nmove {
            case .right:
                if coord.x < rlen - 1 {
                    let ncoord = Coord(coord.x + 1, coord.y)
                    appendIfNeeded(ncoord, nmove, thl)
                }
            case .down:
                if coord.y < clen - 1 {
                    let ncoord = Coord(coord.x, coord.y + 1)
                    appendIfNeeded(ncoord, nmove, thl)
                }
            case .left:
                if coord.x > 0 {
                    let ncoord = Coord(coord.x - 1, coord.y)
                    appendIfNeeded(ncoord, nmove, thl)
                }
            case .up:
                if coord.y > 0 {
                    let ncoord = Coord(coord.x, coord.y - 1)
                    appendIfNeeded(ncoord, nmove, thl)
                }
            default:
                fatalError()
            }
        }
    }
    
    return state[end]!.filter({
        switch $0.key {
        case .down(let c):
            return c >= min
        case .up(let c):
            return c >= min
        case .left(let c):
            return c >= min
        case .right(let c):
            return c >= min
        default:
            return false
        }
    }).values.min()! - Int(String(input.first!))!
}

func minHeatLoss(_ input: String) -> Int {
    assert(solution("""
11
21
11
""", 0, 1) == 4)
    assert(solution("""
24
32
""", 0, 3) == 5)
    assert(solution("""
241
321
""", 0, 3) == 6)
    assert(solution("""
11111
22221
""", 0, 3) == 6)
    assert(solution("""
241343231
321545353
325524565
""", 0, 3) == 37)
    assert(solution("""
24134
32154
""", 0, 3) == 15)
    assert(solution("""
241343
321545
""", 0, 3) == 20)
    
    assert(solution("""
2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533
""", 0, 3) == 102)
    
    return solution(input)
}

func minHeatLossUltra(_ input: String) -> Int {
    assert(solution("""
111111111111
999999999991
999999999991
999999999991
999999999991
""", 4, 10) == 71)
    
    assert(solution("""
2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533
""", 4, 10) == 94)
    
    return solution(input, 4, 10)
}
