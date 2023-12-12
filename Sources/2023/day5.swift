struct Transform {
    let dest: Int
    let source: Int
    let len: Int
    
    init(_ dest: Int, _ source: Int, _ len: Int) {
        self.dest = dest
        self.source = source
        self.len = len
    }
    
    func applicable(_ val: Int) -> Bool {
        (source...(source + len)).contains(val)
    }
    
    func apply(_ val: Int) -> Int {
        val - source + dest
    }
    
    func applied(_ range: ClosedRange<Int>) -> [ClosedRange<Int>]? {
        let intersection = range.clamped(to: (source...(source + len)))
        if intersection.lowerBound != intersection.upperBound {
            let lb = dest + intersection.lowerBound - source
            let ub = dest + intersection.upperBound - source
            let bounds = [(lb, ub), (range.lowerBound, intersection.lowerBound), (intersection.upperBound, range.upperBound)]
            return bounds.filter({ $0.0 != $0.1 }).map({ $0...$1 })
        } else {
            return nil
        }
    }
}

struct Map {
    let transforms: [Transform]
    
    init(_ transforms: [Transform]) {
        self.transforms = transforms
    }
    
    func apply(_ val: Int) -> Int {
        self.transforms.first(where: { $0.applicable(val) })?.apply(val) ?? val
    }
    
    func resolve(_ range: ClosedRange<Int>) -> [ClosedRange<Int>] {
        var ranges = [range]
        var output: [ClosedRange<Int>] = []
        for transform in transforms {
            if ranges.isEmpty { break }
            let r = ranges.removeFirst()
            if let res = transform.applied(r) {
                output.append(res[0])
                ranges.append(contentsOf: res[1...])
            } else {
                ranges.append(r)
            }
        }
        return output + ranges
    }
}

func resolveAlmanac(_ input: String) -> Int {
    func solution(_ almanac: String) -> [Int] {
        var seeds: [Int] = []
        var maps: [Map] = []
        
        let lines = almanac.components(separatedBy: "\n\n")
        
        for line in lines {
            if line.starts(with: "seeds") {
                line.components(separatedBy: ": ").last?
                    .split(separator: " ")
                    .compactMap({ Int($0) })
                    .forEach({ seeds.append($0) })
            } else {
                var transforms = [Transform]()
                line.components(separatedBy: ":\n").last?.split(separator: "\n").forEach { substr in
                    let val = substr.split(separator: " ").compactMap({ Int($0) })
                    let t = Transform(val[0], val[1], val[2])
                    transforms.append(t)
                }
                maps.append(Map(transforms))
            }
        }
        
        return seeds.map { seed in
            var res = seed
            maps.forEach({ res = $0.apply(res) })
            return res
        }
    }
    
    { // assertions
        assert(solution("""
seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
""") == [82, 43, 86, 35])
    }()
    
    return solution(input).min()!
}

func resolveAlmanacRanged(_ input: String) -> Int {
    func solution(_ almanac: String) -> Int {
        var seeds: [Int] = []
        var maps: [Map] = []
        
        let lines = almanac.components(separatedBy: "\n\n")
        
        for line in lines {
            if line.starts(with: "seeds") {
                line.components(separatedBy: ": ").last?
                    .split(separator: " ")
                    .compactMap({ Int($0) })
                    .forEach({ seeds.append($0) })
            } else {
                var transforms = [Transform]()
                line.components(separatedBy: ":\n").last?.split(separator: "\n").forEach { substr in
                    let val = substr.split(separator: " ").compactMap({ Int($0) })
                    let t = Transform(val[0], val[1], val[2])
                    transforms.append(t)
                }
                maps.append(Map(transforms))
            }
        }
        
        var i = 0
        var output = Int.max
        while i < seeds.count {
            let ss = seeds[i]
            let sl = seeds[i + 1]
            output = min(output, ss)
            
            var ranges = [ss...(ss + sl)]
            for m in maps {
                ranges = ranges.compactMap(m.resolve(_:)).flatMap { $0 }
            }
            let candidate = ranges.map({ $0.lowerBound }).min()!
            output = min(output, candidate)
            i += 2
        }
        
        return output
    }
    
    { // assertions
        assert(solution("""
seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
""") == 46)
    }()
    
    return solution(input)
}
