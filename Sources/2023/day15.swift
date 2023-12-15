// hash(X) = ASCII(X) * 17 mod 256

private func hasher(_ inp: String) -> Int {
    func h(_ seed: Int, _ ch: Character) -> Int {
        guard let val = ch.asciiValue else { return 0 }
        return (seed + Int(val)) * 17 % 256
    }
    
    return inp
        .components(separatedBy: ",")
        .map({ s in s.reduce(0, h) })
        .reduce(0, +)
}

class Lense {
    var label: String
    var power: Int
    
    init(_ label: String, _ power: Int) {
        self.label = label
        self.power = power
    }
}

private func lensPower(_ inp: String) -> Int {
    var boxes: [Int: [Lense]] = [:]
    
    func h(_ seed: Int, _ ch: Character) -> Int {
        guard let val = ch.asciiValue else { return 0 }
        return (seed + Int(val)) * 17 % 256
    }
    
    inp.components(separatedBy: ",")
        .forEach({ s in
            if s.hasSuffix("-"), let label = s.components(separatedBy: "-").first {
                let h = label.reduce(0, h)
                boxes[h]?.removeAll(where: { $0.label == label })
            }
            if s.contains("=") {
                let comp = s.components(separatedBy: "=")
                let h = comp[0].reduce(0, h)
                if let l = boxes[h]?.first(where: { $0.label == comp[0] }) {
                    l.power = Int(comp[1])!
                } else {
                    boxes[h, default: []].append(Lense(comp[0], Int(comp[1])!))
                }
            }
        })
    let sum = boxes.map({ box in
        box.value.enumerated().reduce(0, { (acc, el) in
            let i = el.offset + 1
            let l = el.element
            return acc + i * l.power * (box.key + 1)
        })
    }).reduce(0, +)
    return sum
}

func lensHasher(_ input: String) -> Int {
    assert(hasher("HASH") == 52)
    assert(hasher("rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7") == 1320)
    return hasher(input.trimmingCharacters(in: .newlines))
}

func lensFocusingPower(_ input: String) -> Int {
    assert(lensPower("rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7") == 145)
    return lensPower(input.trimmingCharacters(in: .newlines))
}
