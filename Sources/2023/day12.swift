import Foundation

func magic_printer(_ p1: String, _ p2: String) {
    print(take4("\(p1) \(p2)", 1))
    print("~~~~~")
    print(take4("\(p1).\(p1) \(p2),\(p2)", 1))
    print(take4("\(p1)#\(p1) \(p2),\(p2)", 1))
    print(take4("\(p1)?\(p1) \(p2),\(p2)", 1))
    print("= ", take4("\(p1) \(p2)", 2))
    print("~~~~~")
    print(take4("\(p1).\(p1).\(p1) \(p2),\(p2),\(p2)", 1))
    print(take4("\(p1).\(p1)#\(p1) \(p2),\(p2),\(p2)", 1))
    print(take4("\(p1)#\(p1).\(p1) \(p2),\(p2),\(p2)", 1))
    print(take4("\(p1)#\(p1)#\(p1) \(p2),\(p2),\(p2)", 1))
    print(take4("\(p1)?\(p1)?\(p1) \(p2),\(p2),\(p2)", 1))
    print("= ", take4("\(p1) \(p2)", 3))
    print("~~~~~")
}

private func take4(_ row: String, _ ufc: Int = 1) -> Int {
    guard !row.isEmpty else { return 0 }
    
    func loop(_ row: String, _ check: [Int], _ word: String) -> Int {
        guard !row.isEmpty else { 
            if check.isEmpty || (check.count == 1 && check.first! == word.count) {
                return 1
            } else {
                return 0
            }
        }
        
        if check.isEmpty {
            return !row.contains("#") && word.isEmpty ? 1 : 0
        }
        
        var row = row
        var check = check
        var word = word
        while !row.isEmpty && !check.isEmpty {
            let ch = row.removeFirst()
            switch ch {
            case "#":
                word += String(ch)
            case ".":
                if !word.isEmpty {
                    if word.count == check.first! {
                        check.removeFirst()
                        word = ""
                    } else {
                        return 0
                    }
                }
            case "?":
                if !word.isEmpty {
                    if word.count > check.first! {
                        return 0
                    } else if word.count == check.first! {
                        check.removeFirst()
                        let c = globalCache[CacheKey(row, Array(check), word)] ?? loop(row, check, "")
                        globalCache[CacheKey(row, Array(check), word)]  = c
                        return c
                    } else {
                        let c = globalCache[CacheKey(row, Array(check), word)] ?? loop(row, check, word + "#")
                        globalCache[CacheKey(row, Array(check), word)]  = c
                        return c
                    }
                } else {
                    let c = globalCache[CacheKey(row, Array(check), word)] ?? loop(row, check, word + "#") + loop(row, check, "")
                    globalCache[CacheKey(row, Array(check), word)]  = c
                    return c
                }
            default:
                return 0
            }
        }
        
        let rp = row.contains("#")
        return !rp && ((check.isEmpty && word.isEmpty) || (check.count == 1 && check.first! == word.count)) ? 1 : 0
    }
    
    let comp = row.components(separatedBy: " ")
    let springs = Array(repeating: comp[0], count: ufc).joined(separator: "?")
    let checksum = Array(repeating: comp[1], count: ufc).joined(separator: ",").components(separatedBy: ",").compactMap(Int.init)
    let count = loop(springs, checksum, "")
    return count
}

struct CacheKey: Hashable {
    var row: String
    var arr: [Int]
    var l: String
    
    init(_ row: String, _ arr: [Int], _ l: String) {
        self.row = row
        self.arr = arr
        self.l = l
    }
}

var globalCache: [CacheKey: Int] = [:]

private func take5(_ row: String, _ ufc: Int = 1) -> Int {
    guard !row.isEmpty else { return 0 }
    
    func loop(_ row: String, _ check: [Int], _ word: String) -> Int {
        guard !row.isEmpty else {
            if check.isEmpty || (check.count == 1 && check.first! == word.count) {
                return 1
            } else {
                return 0
            }
        }
        
        if let cache = globalCache[CacheKey(row, check, word)] {
            return cache
        }
        
        if check.isEmpty {
            return !row.contains("#") && word.isEmpty ? 1 : 0
        }
        
        var row = row
        var check = check
        var word = word
        while !row.isEmpty && !check.isEmpty {
            let ch = row.removeFirst()
            switch ch {
            case "#":
                word += String(ch)
            case ".":
                if !word.isEmpty {
                    if word.count == check.first! {
                        check.removeFirst()
                        word = ""
                    } else {
                        return 0
                    }
                }
            case "?":
                if !word.isEmpty {
                    if word.count > check.first! {
                        return 0
                    } else if word.count == check.first! {
                        check.removeFirst()
                        let c = loop(row, check, "")
//                        let c = globalCache[CacheKey(row, check, "")] ?? loop(row, check, "")
                        globalCache[CacheKey(row, check, "")] = c
                        return c
                    } else {
                        let c = loop(row, check, word + "#")
//                        let c = globalCache[CacheKey(row, check, word + "#")] ?? loop(row, check, word + "#")
                        globalCache[CacheKey(row, check, word + "#")] = c
                        return c
                    }
                } else {
                    let c1 = loop(row, check, word + "#")
//                    let c1 = globalCache[CacheKey(row, check, word + "#")] ?? loop(row, check, word + "#")
                    globalCache[CacheKey(row, check, word + "#")] = c1
                    let c2 = loop(row, check, "")
//                    let c2 = globalCache[CacheKey(row, check, "")] ?? loop(row, check, "")
                    globalCache[CacheKey(row, check, "")] = c2
                    return c1 + c2
                }
            default:
                return 0
            }
        }
        
        let rp = row.contains("#")
        return !rp && ((check.isEmpty && word.isEmpty) || (check.count == 1 && check.first! == word.count)) ? 1 : 0
    }
    
    
    // 1. reduce row
    //      #??...?##..# -> #??.?##.#
    // 2. split by slots
    //      #??.?##.# -> [#??, ?##, #]
    // 3. explode by N
    //      [#??, ?##, #] -> [[#??, ?##, #, #??, ?##, #], [#??, ?##, ##??, ?##, #]]
    
    /*
     1+2+3+4+5
     1+2+3+4-5
     1+2+3-4+5
     1+2+3-4-5
     1+2-3+4+5
     1+2-3+4-5
     1+2-3-4+5
     1+2-3-4-5
     1-2+3+4+5
     1-2+3+4-5
     1-2+3-4+5
     1-2+3-4-5
     1-2-3+4+5
     1-2-3+4-5
     1-2-3-4+5
     1-2-3-4-5
     */
    let comp = row.components(separatedBy: " ")
    
    func permutations(_ springs: [String]) -> [String] {
        guard springs.count > 1 else { return springs }
        var springs = springs
        let first = springs.removeFirst()
        return permutations(springs).map({ first + "." + $0 }) + permutations(springs).map({ first + "#" + $0 })
    }
    
    var springs = permutations(Array(repeating: comp[0], count: ufc))
        .compactMap({ sp in
            var pch = Character(" ")
            return sp.filter({
                if pch == "." && $0 == pch {
                    pch = $0
                    return false
                } else {
                    pch = $0
                    return true
                }
            })
        })
    springs = Array(Set(springs))
    let checksum = Array(repeating: comp[1], count: ufc).joined(separator: ",").components(separatedBy: ",").compactMap(Int.init)
    
    var res: [Int] = []
    for spring in springs {
        var candidates: [Int: Int] = [:]
        let comps = spring.components(separatedBy: ".").filter({ !$0.isEmpty })
        for sc in comps {
            if candidates.isEmpty {
                for i in 0..<checksum.count {
                    let c = loop(sc, Array(checksum[...i]), "")
//                    let c = globalCache[CacheKey(sc, Array(checksum[...i]), "")] ?? loop(sc, Array(checksum[...i]), "")
//                    let val = candidates[i + 1, default: 0]
                    if c > 0 {
                        candidates[i + 1] = c
                    }
//                    globalCache[CacheKey(sc, Array(checksum[...i]), "")] = c
                    candidates[1] = candidates[1, default: 0]
                }
            } else {
                for (j, cc) in candidates.sorted(by: { $0.key < $1.key }) {
                    for i in j..<checksum.count {
                        let c = loop(sc, Array(checksum[j...i]), "")
//                        let c = globalCache[CacheKey(sc, Array(checksum[j...i]), "")] ?? loop(sc, Array(checksum[j...i]), "")
//                        if c > 0 {
                        if c > 0 {
                            candidates[i + 1, default: 0] += c * cc
                        }
//                        globalCache[CacheKey(sc, Array(checksum[j...i]), "")] = c
//                        }
                    }
                }
            }
        }
        
        var result = candidates.filter({ $0.0 == checksum.count }).first(where: { $0.0 == checksum.count })?.1 ?? 0
        res.append(result)
        globalCache.removeAll()
    }
    return res.reduce(0, +)
}

func countArrangementsOfSprings2(_ input: String) -> Int {
    assert(take5("?#?#?#?#?#?#?#? 1,3,1,6") == 1)
    assert(take5(".?????. 1,1,1") == 1)
    assert(take5(".??..??...?##. 1,1,3") == 4)
    assert(take5(".?###?. 4") == 2)
    assert(take5(".?####. 4") == 1)
    assert(take5(".?####. 5") == 1)
    assert(take5(".?????. 4") == 2)
    assert(take5(".?????. 1,1") == 6)
    assert(take5("?###???????? 3,2,1") == 10)
    assert(take5("????.#...#... 4,1,1") == 1)
    assert(take5("????.######..#####. 1,6,5") == 4)
    
    return input.components(separatedBy: "\n")
        .map({ take5($0) })
        .reduce(0, +)
}

func countArrangementsOfSprings(_ input: String) -> Int {
    assert(take4(".?????. 1,1,1") == 1)
    assert(take4(".?###?. 4") == 2)
    assert(take4(".?####. 4") == 1)
    assert(take4(".?####. 5") == 1)
    assert(take4(".?????. 4") == 2)
    assert(take4(".?????. 1,1") == 6)
    assert(take4("?###???????? 3,2,1") == 10)
    assert(take4(".??..??...?##. 1,1,3") == 4)
    assert(take4("????.#...#... 4,1,1") == 1)
    assert(take4("?#?#?#?#?#?#?#? 1,3,1,6") == 1)
    assert(take4("????.######..#####. 1,6,5") == 4)
    
    return input.components(separatedBy: "\n")
        .map({ take4($0) })
        .reduce(0, +)
}


func helper(_ input: String, _ rep: Int) -> Double {
    guard !input.isEmpty else { return 0 }
    
    func extend(_ row: String) -> [String] {
        let icomp = input.components(separatedBy: " ")
        let comp = row.components(separatedBy: " ")
        let p1 = comp[0] + "." + icomp[0]
        let p2 = comp[0] + "#" + icomp[0]
        let e = comp[1] + "," + icomp[1]
        return [
            p1 + " " + e,
            p2 + " " + e,
        ]
    }
    
    let input0 = Double(take4(input))
    let inputs = extend(input)
    let basis = [
        Double(take4(inputs[0])) / input0,
        Double(take4(inputs[1])) / input0,
    ]
    var output = [input0]
    var rep = rep
    while rep > 1 {
        output = output.map({ $0 * basis[0] }) + output.map({ $0 * basis[1] })
        rep -= 1
    }
    return output.reduce(0, +)
}

func countUnfoldedArrangementsOfSprings(_ input: String) -> Int {
    assert(take5("?###???????? 3,2,1", 5) == 506250)
    assert(take5(".??..??...?##. 1,1,3", 5) == 16384)
    assert(take5("????? 1", 2) == 45)
    assert(take5("??????????? 1,1", 1) == 45)
    assert(take5("????.#...#... 4,1,1", 5) == 16)
    assert(take5("???.### 1,1,3", 5) == 1)
    assert(take5("?#?#?#?#?#?#?#? 1,3,1,6", 5) == 1)
    assert(take5("????.######..#####. 1,6,5", 5) == 2500)
   
    let res = input.components(separatedBy: "\n").enumerated()
        .map({ i, c in if i % 10 == 0 { print(i) } ; return take5(c, 5) })
        .reduce(0, +)
    return Int(res)
}

/*
 Day 12
     Part 1: 7843
     Part 2: 4930207719633
             3152965890662
             3553544002333
             1702887982868


35 cutoff
 \wo cache: 554017870
 \w cache:  554017870
            554017870
 */
