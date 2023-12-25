private func solution(_ input: String) -> Int {
    func components(_ graph: [String: Set<String>]) -> [Int] {
        var components: [Set<String>] = []
        var visited: Set<String> = []
        while visited.count != graph.count {
            components.append([])
            var queue: Set<String> = [Set(graph.keys).subtracting(visited).first!]
            while !queue.isEmpty {
                let v = queue.removeFirst()
                if visited.contains(v) { continue }
                visited.insert(v)
                components[components.count - 1].insert(v)
                queue.formUnion(graph[v]!)
            }
        }
        return components.map { $0.count }
    }
    
    let lines = input.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
    
    var map: [String: Set<String>] = [:]
    var edges: [(String, String)] = []
    for line in lines {
        let comps = line.components(separatedBy: ": ")
        let vertices = Set(comps[1].components(separatedBy: " "))
        map[comps[0], default: []].formUnion(vertices)
        vertices.forEach({
            map[$0, default: []].insert(comps[0])
            edges.append((comps[0], $0))
        })
    }
    
    for i in 0..<edges.count {
        for j in i..<edges.count {
            for k in j..<edges.count {
                let triplet = [
                    edges[i],
                    edges[j],
                    edges[k],
                ]
                print(i, j, k)
                var m = map
                for edge in triplet {
                    m[edge.0]!.remove(edge.1)
                    m[edge.1]!.remove(edge.0)
                }
                let c = components(m)
                if c.count == 2 {
                    return c.reduce(1, *)
                }
            }
        }
    }
    
    
    return 0
}

func disconnectWires(_ input: String) -> Int {
    assert(solution("""
jqt: rhn xhk nvd
rsh: frs pzl lsr
xhk: hfx
cmg: qnr nvd lhk bvb
rhn: xhk bvb hfx
bvb: xhk hfx
pzl: lsr hfx nvd
qnr: nvd
ntq: jqt hfx bvb xhk
nvd: lhk
lsr: lhk
rzs: qnr cmg lsr rsh
frs: qnr lhk lsr
""") == 54)
    // This will take ages so falling back to Stoer-Wagner mincut
    // alg implementation in networkx in day25 notebook
    return solution(input)
}
