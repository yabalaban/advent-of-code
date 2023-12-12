func countPoints(_ input: String) -> Int {
    func solution(_ card: String) -> Int {
        let comp = String(card.components(separatedBy: ": ").last!).components(separatedBy: " | ")
        let winning = Set(comp.first?.split(separator: " ").compactMap({ Int($0) }) ?? [])
        let inp = Set(comp.last?.split(separator: " ").compactMap({ Int($0) }) ?? [])
        let match = winning.intersection(inp)
        
        if match.count > 0 {
            return  1 << (match.count - 1)
        } else {
            return 0
        }
    }
    
    { // assertions
        assert(solution("Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53") == 8)
        assert(solution("Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19") == 2)
        assert(solution("Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1") == 2)
        assert(solution("Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83") == 1)
        assert(solution("Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36") == 0)
        assert(solution("Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11") == 0)
    }()
    return input.split(separator: "\n")
        .map(String.init)
        .compactMap({ solution($0) })
        .reduce(0, +)
}

func countScratchcard(_ input: String) -> Int {
    func solution(_ card: String, _ state: inout [Int: Int]) {
        let comp = card.components(separatedBy: ": ")
        let id = Int(comp.first!.split(separator: " ").last!)!
        let numbers = comp.last!.components(separatedBy: " | ")
        let winning = Set(numbers.first?.split(separator: " ").compactMap({ Int($0) }) ?? [])
        let inp = Set(numbers.last?.split(separator: " ").compactMap({ Int($0) }) ?? [])
        let match = winning.intersection(inp).count
        
        let bump = state[id, default: 0] + 1
        state[id] = bump
        if match > 0 {
            for i in (id + 1)...(id + match) {
                state[i] = state[i, default: 0] + bump
            }
        }
    }
    
    { // assertions
        var state = [Int: Int]()
        let cards = [
            "Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53",
            "Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19",
            "Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1",
            "Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83",
            "Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36",
            "Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11",
        ]
        cards.forEach({ solution($0, &state) })
        assert(state.values.reduce(0, +) == 30)
    }()
    
    var state = [Int: Int]()
    for line in input.split(separator: "\n").map(String.init) {
        solution(line, &state)
    }
    return state.values.reduce(0, +)
}

