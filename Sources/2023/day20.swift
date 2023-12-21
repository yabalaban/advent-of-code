private enum Pulse {
    case low
    case high
}

private class Module: CustomDebugStringConvertible {
    var name: String
    var destination: [String]
    var lpCount: Int = 0
    var hpCount: Int = 0
    
    init(_ name: String, _ destination: [String]) {
        self.name = name
        self.destination = destination
    }
    
    func reset() {
        lpCount = 0
        hpCount = 0
    }
    
    func register(_ senders: [String]) { }
    
    func receive(_ p: Pulse, _ sender: String, _ modules: [String: Module]) -> [(String, Pulse)] {
        fatalError()
    }
    
    var debugDescription: String {
        "\(type(of: self)): \(name)"
    }
}

private class FlipFlop: Module {
    var on: Bool = false
    
    override func receive(_ p: Pulse, _ sender: String, _ modules: [String: Module]) -> [(String, Pulse)] {
        guard p == .low else { return [] }
        defer { self.on.toggle() }
        let np: Pulse = self.on ? .low : .high
        switch np {
        case .high:
            self.hpCount += destination.count
        case .low:
            self.lpCount += destination.count
        }
        return destination.map({ ($0, np) })
    }
}

private class Conjunction: Module {
    var memory: [String: Pulse] = [:]
    var cache: [[Bool]: Pulse] = [:]
    
    override func register(_ senders: [String]) {
        senders.forEach({
            memory[$0] = .low
        })
    }
    
    override func receive(_ p: Pulse, _ sender: String, _ modules: [String: Module]) -> [(String, Pulse)] {
        memory[sender] = p
        let np: Pulse = memory.values.allSatisfy({ $0 == .high }) ? .low : .high
        switch np {
        case .high:
            self.hpCount += destination.count
        case .low:
            self.lpCount += destination.count
        }
        return destination.map({ ($0, np) })
    }
}

private class Broadcast: Module {
    override func receive(_ p: Pulse, _ sender: String, _ modules: [String: Module]) -> [(String, Pulse)] {
        switch p {
        case .high:
            self.hpCount += destination.count
        case .low:
            self.lpCount += destination.count
        }
        return destination.map({ ($0, p) })
    }
}

private class Untyped: Module {
    override func receive(_ p: Pulse, _ sender: String, _ modules: [String: Module]) -> [(String, Pulse)] {
        return []
    }
}

private class Button: Module {
    override func receive(_ p: Pulse, _ sender: String, _ modules: [String: Module]) -> [(String, Pulse)] {
        self.lpCount += 1
        return [("broadcaster", .low)]
    }
}

private class CompressedModule: Module {
    let input: FlipFlop
    let output: Module
    let state: [String]
    
    init(input: FlipFlop, output: Module, state: [String]) {
        self.input = input
        self.output = output
        self.state = state
        super.init(input.name, output.destination)
    }
    
    override func receive(_ p: Pulse, _ sender: String, _ modules: [String: Module]) -> [(String, Pulse)] {
        var queue: [(String, String, Pulse)] = [(sender, input.name, p)]
        var out: [(String, Pulse)] = []
        while !queue.isEmpty {
            let (sender, name, pulse) = queue.removeFirst()
            let module = if name == self.name {
                input
            } else {
                modules[name, default: Untyped(name, [])]
            }
            let resp = module.receive(pulse, sender, modules)
            if module.name == output.name {
                out.append(contentsOf: resp)
            } else {
                queue.append(contentsOf: resp.map({ (name, $0.0, $0.1) }))
            }
        }
        
        return out
    }
}

private class Rx: Module {
    var enabled: Bool = false
    
    override func receive(_ p: Pulse, _ sender: String, _ modules: [String: Module]) -> [(String, Pulse)] {
        if p == .low {
            enabled = true
        }
        self.lpCount += 1
        return []
    }
}

private func makeModules(_ input: String, _ start: [String: Module]) -> [String: Module] {
    let wires = input.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
    
    var modules: [String: Module] = start
    var destinations = [String: [String]]()
    var conjunctions = Set<String>()
    for wire in wires {
        let comp = wire.components(separatedBy: " -> ")
        let dest = comp[1].components(separatedBy: ", ")
        switch comp[0] {
        case "broadcaster":
            modules["broadcaster"] = Broadcast("broadcaster", dest)
            destinations["modules"] = dest
        case let fname where fname.hasPrefix("%"):
            let name = String(fname.dropFirst())
            modules[name] = FlipFlop(name, dest)
            destinations[name] = dest
        case let fname where fname.hasPrefix("&"):
            let name = String(fname.dropFirst())
            modules[name] = Conjunction(name, dest)
            destinations[name] = dest
            conjunctions.insert(name)
        default:
            fatalError(comp[0])
        }
    }
    
    var conjunctionMap = [String: [String]]()
    for conjunction in conjunctions {
        for module in modules.values {
            if module.destination.contains(conjunction) {
                conjunctionMap[conjunction, default: []].append(module.name)
            }
        }
    }
    for name in conjunctionMap.keys {
        modules[name]!.register(conjunctionMap[name]!)
    }
    
    return modules
}

private func compress(_ modules: [String: Module]) -> [String: Module] {
    var modules = modules
    
    let conjs = modules.values.compactMap({ $0 as? Conjunction })
    for conj in conjs {
        let flipFlops = conj.memory.keys.map({ modules[$0]! }).compactMap({ $0 as? FlipFlop })
        if flipFlops.count == conj.memory.count {
            var ffd = Set<String>([conj.name])
            
            var queue: [Module] = flipFlops
            while !queue.isEmpty {
                let m = queue.removeFirst()
                for dest in m.destination {
                    if !ffd.contains(dest) {
                        ffd.insert(dest)
                        queue.append(modules[dest]!)
                    }
                }
            }
            
            let inputs = Set(flipFlops.map({ $0.name })).subtracting(ffd)
            guard inputs.count == 1 else { continue }
            let input = modules[inputs.first!] as! FlipFlop
            let outputs = Set(conj.destination).subtracting(ffd).subtracting(inputs)
            guard outputs.count == 1 else { continue }
            let output = modules[outputs.first!]!
        
            modules[inputs.first!] = CompressedModule(input: input, output: output, state: ffd.sorted())
        }
    }
    
    return modules
}

private func countPulses(_ input: String, _ buttonTaps: Int, _ compressed: Bool = false) -> Int {
    var modules = makeModules(input, ["button": Button("button", ["broadcaster"])])

    var totalLow = 0
    var totalHigh = 0
    
    for _ in 0..<buttonTaps {
        var queue: [(String, String, Pulse)] = [("elf", "button", .low)]
        while !queue.isEmpty {
            let (sender, name, pulse) = queue.removeFirst()
            let module = modules[name, default: Untyped(name, [])]
            modules[name] = module
            let resp = module.receive(pulse, sender, modules)
            queue.append(contentsOf: resp.map({ (name, $0.0, $0.1) }))
        }
        
        totalLow += modules.values.map({ $0.lpCount }).reduce(0, +)
        totalHigh += modules.values.map({ $0.hpCount }).reduce(0, +)
      
        modules.values.forEach({ $0.reset() })
    }
    
    return totalLow * totalHigh
}

private func countButtonTaps(_ input: String) -> Int {
    var modules = makeModules(input, ["button": Button("button", ["broadcaster"]), "rx": Rx("rx", [])])
    
    modules = compress(modules)
    
    let cmcount = modules.values.filter({ $0 is CompressedModule }).count
    var cycles: [String: Int] = [:]
    var cycle = 1
    
    while cycles.count != cmcount {
        var queue: [(String, String, Pulse)] = [("elf", "button", .low)]
        while !queue.isEmpty {
            let (sender, name, pulse) = queue.removeFirst()
            let module = modules[name, default: Untyped(name, [])]
            modules[name] = module
            let resp = module.receive(pulse, sender, modules)
            if module is CompressedModule, resp.contains(where: { $0.1 == .high }) {
                cycles[module.name] = cycle
                if cycles.count == cmcount {
                    break
                }
            }
            queue.append(contentsOf: resp.map({ (name, $0.0, $0.1) }))
        }
        cycle += 1
    }
    
    return lcm(cycles.values.map({ $0 }))
}

func countPulses(_ input: String) -> Int {
    assert(countPulses("""
broadcaster -> a, b, c
%a -> b
%b -> c
%c -> inv
&inv -> a
""", 1000, true) == 32000000)
    assert(countPulses("""
broadcaster -> a
%a -> inv, con
&inv -> b
%b -> con
&con -> output
""", 1000, true) == 11687500)
   
    return countPulses(input, 1000, true)
}

func countButtonTapsToRx(_ input: String) -> Int {
    countButtonTaps(input)
}
