private struct Part: RawRepresentable {
    typealias RawValue = String
    
    let ratings: [String: Int]
    
    init?(rawValue: String) {
        self.ratings = rawValue.trimmingCharacters(in: .alphanumerics.inverted)
            .components(separatedBy: ",")
            .map({ $0.components(separatedBy: "=") })
            .reduce(into: [:], { acc, c in acc[c[0]] = Int(c[1])! })
    }
    
    var rawValue: String {
        "{x=\(ratings["x"]!),m=\(ratings["m"]!),a=\(ratings["a"]!),s=\(ratings["s"]!)}"
    }
}

private enum Condition: RawRepresentable, CustomDebugStringConvertible {
    typealias RawValue = String
    
    case g(String, Int, String)
    case l(String, Int, String)
    case fallback(String)
    
    init?(rawValue: String) {
        let comp = rawValue.components(separatedBy: ":")
        if comp.count == 1 {
            self = .fallback(comp[0])
        } else {
            if comp[0].contains("<") {
                let tmp = comp[0].components(separatedBy: "<")
                self = .l(tmp[0], Int(tmp[1])!, comp[1])
            } else {
                let tmp = comp[0].components(separatedBy: ">")
                self = .g(tmp[0], Int(tmp[1])!, comp[1])
            }
        }
    }
    
    var rawValue: String {
        switch self {
        case .g(let p, let v, let r):
            "\(p)>\(v):\(r)"
        case .l(let p, let v, let r):
            "\(p)<\(v):\(r)"
        case .fallback(let p):
            "\(p)"
        }
    }
    
    var debugDescription: String {
        rawValue
    }
    
    var inverted: Condition {
        switch self {
        case .g(let p, let v, let r):
            return .l(p, v + 1, r)
        case .l(let p, let v, let r):
            return .g(p, v - 1, r)
        case .fallback:
            return self
        }
    }
}

private struct Workflow: RawRepresentable {
    
    typealias RawValue = String
    
    let name: String
    let raw: String
    let conditions: [Condition]
    
    init?(rawValue: String) {
        self.raw = rawValue
        let comp = raw.trimmingCharacters(in: .alphanumerics.inverted)
            .components(separatedBy: "{")
        self.name = comp[0]
        self.conditions = comp[1].components(separatedBy: ",").compactMap(Condition.init(rawValue:))
    }
    
    var rawValue: String {
        raw
    }
    
    func resolve(_ part: Part) -> String {
        for condition in conditions {
            switch condition {
            case .fallback(let p):
                return p
            case .g(let c, let v, let o):
                if part.ratings[c]! > v {
                    return o
                }
            case .l(let c, let v, let o):
                if part.ratings[c]! < v {
                    return o
                }
            }
        }
        fatalError()
    }
    
    func reduce(_ map: [String: Workflow]) -> [[Condition]] {
        var branches = [[Condition]]()
        var branch = [Condition]()
        
        for condition in conditions {
            switch condition {
            case .fallback(let o):
                switch o {
                case "A":
                    branch.append(condition)
                    branches.append(branch)
                case "R":
                    continue
                default:
                    let inner = map[o]!.reduce(map)
                    if !inner.isEmpty {
                        inner.forEach {
                            branches.append(branch + [condition] + $0)
                        }
                    }
                }
            case .g(_, _, let o):
                switch o {
                case "A":
                    branch.append(condition)
                    branches.append(branch)
                    branch = branch.dropLast()
                    branch.append(condition.inverted)
                case "R":
                    branch.append(condition.inverted)
                default:
                    let inner = map[o]!.reduce(map)
                    if !inner.isEmpty {
                        inner.forEach {
                            branches.append(branch + [condition] + $0)
                        }
                    }
                    branch.append(condition.inverted)
                }
            case .l(_, _, let o):
                switch o {
                case "A":
                    branch.append(condition)
                    branches.append(branch)
                    branch = branch.dropLast()
                    branch.append(condition.inverted)
                case "R":
                    branch.append(condition.inverted)
                default:
                    let inner = map[o]!.reduce(map)
                    if !inner.isEmpty {
                        inner.forEach {
                            branches.append(branch + [condition] + $0)
                        }
                    }
                    branch.append(condition.inverted)
                }
            }
        }
        
        return branches
    }
}

private func solution(_ input: String) -> Int {
    let comp = input.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n\n")
    let workflows = comp[0].components(separatedBy: "\n").compactMap(Workflow.init(rawValue:))
    let parts = comp[1].components(separatedBy: "\n").compactMap(Part.init(rawValue:))
    let workflowsMap = workflows.reduce(into: [:], { $0[$1.name] = $1 })
    
    var accepted: [Part] = []
    for part in parts {
        var r = "in"
        
        repeat {
            let workflow = workflowsMap[r]!
            r = workflow.resolve(part)
        } while r != "A" && r != "R"
        
        if r == "A" {
            accepted.append(part)
        }
    }
    
    let total = accepted.map({ $0.ratings.values.reduce(0, +) }).reduce(0, +)
    return total
}

private struct RatingsRange {
    let x: ClosedRange<Int>
    let m: ClosedRange<Int>
    let a: ClosedRange<Int>
    let s: ClosedRange<Int>
    
    init(_ x: ClosedRange<Int>, _ m: ClosedRange<Int>, _ a: ClosedRange<Int>, _ s: ClosedRange<Int>) {
        self.x = x
        self.m = m
        self.a = a
        self.s = s
    }
}

private func difference(_ lhs: ClosedRange<Int>, _ rhs: [ClosedRange<Int>]) -> [ClosedRange<Int>] {
    guard !rhs.isEmpty else { return [lhs] }
    
    var output = [lhs]
    for range in rhs {
        var result: [ClosedRange<Int>] = []
        while !output.isEmpty {
            let r = output.removeFirst()
            if r.overlaps(range) {
                let inter = r.clamped(to: range)
                if r.lowerBound < inter.lowerBound {
                    result.append(r.lowerBound...(inter.lowerBound - 1))
                }
                if r.upperBound > inter.upperBound {
                    result.append((inter.upperBound + 1)...r.upperBound)
                }
            } else {
                result.append(r)
            }
        }
        output = result
    }
    
    return output
}

private func combinations(_ input: String) -> Int {
    let comp = input.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n\n")
    let workflows = comp[0].components(separatedBy: "\n").compactMap(Workflow.init(rawValue:))
    let workflowsMap = workflows.reduce(into: [:], { $0[$1.name] = $1 })
    
    let reduce = workflowsMap["in"]!.reduce(workflowsMap)
    
    var ranges: [RatingsRange] = []
    
    for path in reduce {
        var maxRatings: [String: Int] = [:]
        var minRatings: [String: Int] = [:]
        
        path.forEach { condition in
            switch condition {
            case .fallback(_):
                break
            case .g(let p, let v, _):
                minRatings[p] = max(minRatings[p] ?? v + 1, v + 1)
            case .l(let p, let v, _):
                maxRatings[p] = min(maxRatings[p] ?? v - 1, v - 1)
            }
        }
        
        let rrange = RatingsRange(
            minRatings["x", default: 1]...maxRatings["x", default: 4000],
            minRatings["m", default: 1]...maxRatings["m", default: 4000],
            minRatings["a", default: 1]...maxRatings["a", default: 4000],
            minRatings["s", default: 1]...maxRatings["s", default: 4000]
        )
        
        ranges.append(rrange)
    }
    
    var total = 0
    for range in ranges {
        total += range.x.count * range.m.count * range.a.count * range.s.count
    }
    
    return total
}

func combineRatingNumbers(_ input: String) -> Int {
    assert(solution("""
px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}
""") == 19114)
    
    return solution(input)
}

func distinctCombinations(_ input: String) -> Int {
    assert(combinations("""
px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}
""") == 167409079868000)
    
    return combinations(input)
}
