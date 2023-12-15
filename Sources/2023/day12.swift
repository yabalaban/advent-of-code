struct CacheKey: Hashable {
    var row: String
    var group: [Int]
    var prefix: String
    
    init(_ row: String, _ group: [Int], _ prefix: String) {
        self.row = row
        self.group = group
        self.prefix = prefix
    }
}

private var cache: [CacheKey: Int] = [:]

private func permutations(_ string: String, _ times: Int) -> [String] {
    guard times > 1 else { return [string] }
    let perm = permutations(string, times - 1)
    return perm.map({ [string + "." + $0, string + "#" + $0] }).flatMap({ $0 })
}

private func resolve(_ row: String, _ group: [Int], _ prefix: String) -> Int {
    if group.isEmpty {
        return !row.contains("#") && prefix.isEmpty ? 1 : 0
    }
    if row.isEmpty {
        return group.count == 1 && group[0] == prefix.count ? 1 : 0
    }
    
    if let cache = cache[CacheKey(row, group, prefix)] {
        return cache
    }
    
    var row = row
    var group = group
    var prefix = prefix
    while !row.isEmpty && !group.isEmpty {
        let ch = row.removeFirst()
        switch ch {
        case "#":
            prefix += String(ch)
        case ".":
            if !prefix.isEmpty {
                if prefix.count == group[0] {
                    group.removeFirst()
                    let c = resolve(row, group, "")
                    cache[CacheKey(row, group, "")] = c
                    return c
                } else {
                    cache[CacheKey(row, group, prefix)] = 0
                    return 0
                }
            }
        case "?":
            if !prefix.isEmpty {
                if prefix.count > group[0] {
                    cache[CacheKey(row, group, prefix)] = 0
                    return 0
                } else if prefix.count == group[0] {
                    group.removeFirst()
                    let c = resolve(row, group, "")
                    cache[CacheKey(row, group, "")] = c
                    return c
                } else {
                    let c = resolve(row, group, prefix + "#")
                    cache[CacheKey(row, group, prefix + "#")] = c
                    return c
                }
            } else {
                let c1 = resolve(row, group, prefix + "#")
                cache[CacheKey(row, group, prefix + "#")] = c1
                let c2 = resolve(row, group, "")
                cache[CacheKey(row, group, "")] = c2
                return c1 + c2
            }
        default:
            return 0
        }
    }
    
    let skippable = !row.contains("#")
    let arranged = group.isEmpty && prefix.isEmpty || group.count == 1 && group[0] == prefix.count
    return skippable && arranged ? 1 : 0
}

private func countArrangements(_ row: String, _ unfold: Int = 1) -> Int {
    guard !row.isEmpty else { return 0 }
    
    let comp = row.components(separatedBy: " ")
    let springs = permutations(comp[0], unfold)
    let checksum = Array(repeating: comp[1], count: unfold).joined(separator: ",").components(separatedBy: ",").compactMap(Int.init)
    
    var res: [Int] = []
    for spring in springs {
        var queue: [Int: [(Int, Int)]] = [0: [(0, 1)]]
        let parts = spring.components(separatedBy: ".").filter({ !$0.isEmpty })
        let skips = parts.map({ !$0.contains("#") })
        for (idx, part) in parts.enumerated() {
            let skippable = skips[idx]
            var skip: [Int: Int] = [:]
            if skippable {
                queue[idx]?.forEach({ skip[$0.0, default: 0] += $0.1 })
            }
            
            var nqueue: [Int: Int] = [:]
            for (offset, val) in queue[idx, default: []] {
                for i in offset..<checksum.count {
                    let count = resolve(part, Array(checksum[offset...i]), "")
                    if count > 0 {
                        nqueue[i + 1, default: 0] += val * count
                    }
                }
            }
            
            queue[idx] = nqueue.filter({ p in
                guard p.0 == checksum.count else { return true }
                return skips[(idx + 1)...].allSatisfy({ $0 })
            })
            queue[idx]?.forEach({ skip[$0.0, default: 0] += $0.1 })
            queue[idx + 1, default: []].append(contentsOf: skip.map({ ($0.key, $0.value) }))
        }
        
        let result = queue.filter({ $0.key < parts.count })
            .map({ $0.value.reduce(into: [:], { acc, v in acc[v.0, default: 0] += v.1 }) })
            .reduce(0, { acc, d in acc + d[checksum.count, default: 0] })
        
        res.append(result)
        cache.removeAll()
    }
    return res.reduce(0, +)
}

func countArrangementsOfSprings(_ input: String) -> Int {
    assert(countArrangements("?.?# 1") == 1)
    assert(countArrangements("???#??? 1") == 1)
    assert(countArrangements("???.??? 1") == 6)
    assert(countArrangements("??????? 1") == 7)
    assert(countArrangements("??#?? 1,1") == 2)
    assert(countArrangements("??.?? 1,1") == 4)
    assert(countArrangements("????? 1,1") == 6)
    assert(countArrangements("?????.????? 1") == 10)
    assert(countArrangements("?????.????? 1,1") == 37)
    assert(countArrangements("?#?#?#?#?#?#?#? 1,3,1,6") == 1)
    assert(countArrangements(".?????. 1,1,1") == 1)
    assert(countArrangements(".??..??...?##. 1,1,3") == 4)
    assert(countArrangements(".?###?. 4") == 2)
    assert(countArrangements(".?####. 4") == 1)
    assert(countArrangements(".?####. 5") == 1)
    assert(countArrangements(".?????. 4") == 2)
    assert(countArrangements(".?????. 1,1") == 6)
    assert(countArrangements("?###???????? 3,2,1") == 10)
    assert(countArrangements("????.#...#... 4,1,1") == 1)
    assert(countArrangements("????.######..#####. 1,6,5") == 4)
    
    return input.components(separatedBy: "\n")
        .map({ countArrangements($0) })
        .reduce(0, +)
}

func countUnfoldedArrangementsOfSprings(_ input: String) -> Int {
    assert(countArrangements(".??..??...?##. 1,1,3", 5) == 16384)
    assert(countArrangements("?????#????? 1") == 1)
    assert(countArrangements("?###???????? 3,2,1", 5) == 506250)
    assert(countArrangements("????? 1", 2) == 45)
    assert(countArrangements("????.#...#... 4,1,1", 5) == 16)
    assert(countArrangements("???.### 1,1,3", 5) == 1)
    assert(countArrangements("?#?#?#?#?#?#?#? 1,3,1,6", 5) == 1)
    assert(countArrangements("????.######..#####. 1,6,5", 5) == 2500)
   
    return input.components(separatedBy: "\n")
        .map({ countArrangements($0, 5) })
        .reduce(0, +)
}
