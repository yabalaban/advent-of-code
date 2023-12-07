//
//  day7.swift
//  aoc2023
//

import Foundation

let labels: [String: Int] = [
    "A": 13,
    "K": 12,
    "Q": 11,
    "J": 10,
    "T": 9,
    "9": 8,
    "8": 7,
    "7": 6,
    "6": 5,
    "5": 4,
    "4": 3,
    "3": 2,
    "2": 1,
]

struct Hand: Comparable {
    enum T: Int {
        case high = 0
        case onePair
        case twoPair
        case three
        case fullHouse
        case four
        case five
    }
    
    let cards: String
    let bid: Int
    var t: T
    
    init(cards: String, bid: Int) {
        self.cards = cards
        self.bid = bid
        
        let c = cards.reduce(into: [:], { $0[$1] = $0[$1, default: 0] + 1 })
        switch c.count {
        case 1:
            self.t = .five
        case 2:
            if Set(c.values).intersection(Set([2, 3])).count == 2 {
                self.t = .fullHouse
            } else {
                self.t = .four
            }
        case 3:
            if c.values.max() == 3 {
                self.t = .three
            } else {
                self.t = .twoPair
            }
        case 4:
            self.t = .onePair
        case 5:
            self.t = .high
        default:
            fatalError()
        }
    }
    
    static func < (lhs: Hand, rhs: Hand) -> Bool {
        if lhs.t == rhs.t {
            for i in 0..<5 {
                let ll = labels[String(lhs.cards[lhs.cards.index(lhs.cards.startIndex, offsetBy: i)])]!
                let rl = labels[String(rhs.cards[rhs.cards.index(rhs.cards.startIndex, offsetBy: i)])]!
                if ll == rl {
                    continue
                } else {
                    return ll < rl
                }
            }
            return false
        } else {
            return lhs.t.rawValue < rhs.t.rawValue
        }
    }
}

func camelCaseRound(_ input: String) -> Int {
    var hands = [Hand]()
    input.split(separator: "\n").forEach { hand in
        let items = hand.split(separator: " ")
        hands.append(Hand(cards: String(items[0]), bid: Int(items[1])!))
    }
    hands.sort()
    return hands.enumerated().reduce(0) { (r, e) in
        let (i, h) = e
        return r + (i + 1) * h.bid
    }
}

let extendedLabels: [String: Int] = [
    "A": 13,
    "K": 12,
    "Q": 11,
    "T": 10,
    "9": 9,
    "8": 8,
    "7": 7,
    "6": 6,
    "5": 5,
    "4": 4,
    "3": 3,
    "2": 2,
    "J": 1,
]

struct JHand: Comparable {
    enum T: Int {
        case high = 0
        case onePair
        case twoPair
        case three
        case fullHouse
        case four
        case five
    }
    
    let cards: String
    let bid: Int
    let t: T
    
    init(cards: String, bid: Int) {
        self.cards = cards
        self.bid = bid
        
        let c = cards.reduce(into: [:], { $0[$1] = $0[$1, default: 0] + 1 })
        switch c.count {
        case 1:
            self.t = .five
        case 2:
            if c["J"] != nil {
                self.t = .five
            } else if Set(c.values).intersection(Set([2, 3])).count == 2 {
                self.t = .fullHouse
            } else {
                self.t = .four
            }
        case 3:
            if c["J"] != nil {
                if c["J"] == 1 && Set(c.values).intersection(Set([2])).count == 1 {
                    self.t = .fullHouse
                } else {
                    self.t = .four
                }
            } else if c.values.max() == 3 {
                self.t = .three
            } else {
                self.t = .twoPair
            }
        case 4:
            if c["J"] != nil {
                if c["J"] == 2 || (c["J"] ==  1 && c.values.max() == 2) { // 251245987
                    self.t = .three
                } else {
                    self.t = .twoPair
                }
            } else {
                self.t = .onePair
            }
        case 5:
            if c["J"] != nil {
                self.t = .onePair
            } else {
                self.t = .high
            }
        default:
            fatalError()
        }
    }
    
    static func < (lhs: JHand, rhs: JHand) -> Bool {
        if lhs.t == rhs.t {
            for i in 0..<5 {
                let ll = extendedLabels[String(lhs.cards[lhs.cards.index(lhs.cards.startIndex, offsetBy: i)])]!
                let rl = extendedLabels[String(rhs.cards[rhs.cards.index(rhs.cards.startIndex, offsetBy: i)])]!
                if ll == rl {
                    continue
                } else {
                    return ll < rl
                }
            }
            return false
        } else {
            return lhs.t.rawValue < rhs.t.rawValue
        }
    }
}

func camelCaseJokersRound(_ input: String) -> Int {
    var hands = [JHand]()
    input.split(separator: "\n").forEach { hand in
        let items = hand.split(separator: " ")
        hands.append(JHand(cards: String(items[0]), bid: Int(items[1])!))
    }
    hands.sort()
    return hands.enumerated().reduce(0) { (r, e) in
        let (i, h) = e
        return r + (i + 1) * h.bid
    }
}

func problem_7a() async throws -> Int {
    guard let url = Bundle.main.url(forResource: "day7", withExtension: "txt") else {
        fatalError()
    }
    { // assertions
        assert(camelCaseRound("""
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
""") == 6440)
    }()

    let input = try String(contentsOfFile: url.path(), encoding: .utf8)
    return camelCaseRound(input)
}

func problem_7b() async throws -> Int {
    guard let url = Bundle.main.url(forResource: "day7", withExtension: "txt") else {
        fatalError()
    }
    { // assertions
        assert(camelCaseJokersRound("""
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
""") == 5905)
    }()
    
    
    let input = try String(contentsOfFile: url.path(), encoding: .utf8)
    return camelCaseJokersRound(input)
}

