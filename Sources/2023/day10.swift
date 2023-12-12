class UnionFind {
    var parent: [Int]
    var size: [Int]
    
    init(_ s: Int) {
        parent = Array(0..<s)
        size = Array(repeating: 1, count: s)
    }
    
    func union(_ lhs: Int, _ rhs: Int) {
        guard var lhsSet = set(of: lhs) else { return }
        guard var rhsSet = set(of: rhs) else { return }
        if lhsSet != rhsSet {
            if size[lhsSet] >= size[rhsSet] {
                (lhsSet, rhsSet) = (rhsSet, lhsSet)
            }
            parent[lhsSet] = rhsSet
            size[rhsSet] += size[lhsSet]
        }
    }
    
    func set(of idx: Int) -> Int? {
        guard parent[idx] != idx else { return idx }
        parent[idx] = set(of: parent[idx])!
        return parent[idx]
    }
}

func buildUnionFind(_ pipes: String, _ rlen: Int) -> UnionFind {
    let uf = UnionFind(pipes.count)
    let nset = Set<Character>(["S", "|", "L", "J"])
    let wset = Set<Character>(["S", "-", "7", "J"])
    
    func north(_ ch: Character, _ i: Int) {
        guard nset.contains(ch) else { return }
        guard i > rlen else { return }
        let nch = pipes[pipes.index(pipes.startIndex, offsetBy: i - rlen)]
        if Set(["S", "|", "7", "F"]).contains(nch) {
            uf.union(i, i - rlen)
        }
    }
    
    func west(_ ch: Character, _ i: Int) {
        guard wset.contains(ch) else { return }
        guard i % rlen > 0 else { return }
        let nch = pipes[pipes.index(pipes.startIndex, offsetBy: i - 1)]
        if Set(["S", "-", "L", "F"]).contains(nch) {
            uf.union(i, i - 1)
        }
    }
    
    for (i, ch) in pipes.enumerated() {
        north(ch, i)
        west(ch, i)
    }
    
    return uf
}

func pipesDepth(_ input: String) -> Int {
    func solution(_ pipes: String) -> Int {
        let rlen = pipes.firstIndex(of: "\n")!.utf16Offset(in: pipes)
        let pipes = pipes.replacingOccurrences(of: "\n", with: "")
        let sidx = pipes.firstIndex(of: "S")!
        let spos = sidx.utf16Offset(in: pipes)
        let uf = buildUnionFind(pipes, rlen)
        return uf.size[uf.set(of: spos)!] / 2
    }
    
    { // assertions
        assert(solution("""
.....
.S-7.
.|.|.
.L-J.
.....
""") == 4)
        assert(solution("""
..F7.
.FJ|.
SJ.L7
|F--J
LJ...
""") == 8)
        assert(solution("""
7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ
""") == 8)
    }()
    
    return solution(input)
}

func pipesEnclosingTiles(_ input: String) -> Int {
    func solution(_ pipes: String) -> Int {
        let rlen = pipes.firstIndex(of: "\n")!.utf16Offset(in: pipes)
        let pipes = pipes.replacingOccurrences(of: "\n", with: "")
        let sidx = pipes.firstIndex(of: "S")!
        let spos = sidx.utf16Offset(in: pipes)
        let uf = buildUnionFind(pipes, rlen)
        let s = uf.set(of: spos)!
        
        // connect not-in-the-main-loop pipes together
        for i in 0..<pipes.count {
            guard uf.set(of: i) != s else { continue }
            if i % rlen > 0 {
                if uf.set(of: i - 1) != s {
                    uf.union(i, i - 1)
                }
            }
            if i > rlen {
                if uf.set(of: i - rlen) != s {
                    uf.union(i, i - rlen)
                }
            }
        }
    
        // Sweeping pipes from left to right:
        // -  If parent is encountered after odd number of S-pipes, mark it as a candidate
        var sweep = Set<Int>()
        var outside = true
        var pch =  Character(" ")
        for (i, ch) in pipes.enumerated() {
            if i % rlen == 0 {
                pch = ch
                outside = true
            }
            
            let set = uf.set(of: i)!
            if set == s {
                if ch == "|" || (pch == "F" && ch == "J") || (pch == "L" && ch == "7") {
                    outside.toggle()
                    pch = ch
                } else if ["F", "L"].contains(ch) {
                    pch = ch
                }
            } else if !outside {
                sweep.insert(set)
            }
        }
        
        // Mark parents who are at the border of the input
        var border = Set<Int>()
        let nrows = pipes.count / rlen
        for i in 0..<rlen {
            border.insert(uf.set(of: i)!)
            border.insert(uf.set(of: pipes.count - i - 1)!)
        }
        for i in 0..<nrows {
            border.insert(uf.set(of: i * rlen)!)
            border.insert(uf.set(of: (i + 1) * rlen - 1)!)
        }

        return sweep.subtracting(border)
            .map({ uf.size[$0] }).reduce(0, +)
    }
    
    { // assertions
        assert(solution("""
.....
.S-7.
.|.|.
.L-J.
.....
""") == 1)
        assert(solution("""
...........
.S-------7.
.|F-----7|.
.||.....||.
.||.....||.
.|L-7.F-J|.
.|..|.|..|.
.L--J.L--J.
...........
""") == 4)
        assert(solution("""
..........
.S------7.
.|F----7|.
.||....||.
.||....||.
.|L-7F-J|.
.|II||II|.
.L--JL--J.
..........
""") == 4)
        assert(solution("""
.F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ...
""") == 8)
    }()
    
    return solution(input)
}
