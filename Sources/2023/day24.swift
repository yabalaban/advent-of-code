import Foundation

private struct Point3D: RawRepresentable, Equatable {
    typealias RawValue = String
    
    let x: Decimal
    let y: Decimal
    let z: Decimal
    
    var rawValue: String {
        "(\(x), \(y), \(z))"
    }
    
    init(_ x: Decimal, _ y: Decimal, _ z: Decimal) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    init?(rawValue: String) {
        let comp = rawValue.components(separatedBy: ", ")
        guard comp.count == 3 else { return nil }
        let val = comp.compactMap({ Double($0) })
        guard val.count == 3 else { return nil }
        self.init(Decimal(val[0]), Decimal(val[1]), Decimal(val[2]))
    }
    
    func adding(_ p: Point3D) -> Point3D {
        Point3D(x + p.x, y + p.y, z + p.z)
    }
}

private struct Line {
    let p0: Point3D
    let p1: Point3D
}

private func intersection(_ l1: Line, _ l2: Line) -> Point3D? {
    let denom = (l1.p0.x - l1.p1.x) * (l2.p0.y - l2.p1.y) - (l1.p0.y - l1.p1.y) * (l2.p0.x - l2.p1.x)
    if denom == 0 {
        return nil
    }
    
    let x = (l1.p0.x * l1.p1.y - l1.p0.y * l1.p1.x) * (l2.p0.x - l2.p1.x) - (l1.p0.x - l1.p1.x) * (l2.p0.x * l2.p1.y - l2.p0.y * l2.p1.x)
    let y = (l1.p0.x * l1.p1.y - l1.p0.y * l1.p1.x) * (l2.p0.y - l2.p1.y) - (l1.p0.y - l1.p1.y) * (l2.p0.x * l2.p1.y - l2.p0.y * l2.p1.x)
    return Point3D(x / denom, y / denom, 0.0)
}

private struct Hailstone: RawRepresentable, Equatable {
    typealias RawValue = String
    
    let position: Point3D
    let velocity: Point3D
    
    var rawValue: String {
        "(\(position) @ \(velocity))"
    }
    
    init?(rawValue: String) {
        let comp = rawValue.components(separatedBy: " @ ")
        guard comp.count == 2 else { return nil }
        let val = comp.compactMap({ Point3D(rawValue: $0) })
        guard val.count == 2 else { return nil }
        self.position = val[0]
        self.velocity = val[1]
    }
}

private func cross(_ h1: Hailstone, _ h2: Hailstone) -> Point3D? {
    let p01 = h1.position
    let p02 = h1.position.adding(h1.velocity)
    let p11 = h2.position
    let p12 = h2.position.adding(h2.velocity)
    if let p = intersection(Line(p0: p01, p1: p02), Line(p0: p11, p1: p12)) {
        let d1x = (p.x - p01.x) / h1.velocity.x
        let d2x = (p.x - p11.x) / h2.velocity.x
        if d1x > 0 && d2x > 0 {
            return p
        }
    }
    return nil
}

private func solution(_ input: String) -> Int {
    let rows = input.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
    let hailstones = rows.compactMap({ Hailstone(rawValue: $0) })
    
    var count = 0
    for i in 0..<hailstones.count {
        for j in (i + 1)..<hailstones.count {
            if let intersection = cross(hailstones[i], hailstones[j]) {
                if [intersection.x, intersection.y].allSatisfy({ (200000000000000...400000000000000).contains($0) }) {
                    count += 1
                }
            }
        }
    }
    
    return count
}

func countIntersectionsInRange(_ input: String) -> Int {
    assert(cross(
        Hailstone(rawValue: "19, 13, 30 @ -2, 1, -2")!,
        Hailstone(rawValue: "18, 19, 22 @ -1, -1, -2")!
    ) == Point3D(Decimal(43) / 3.0, Decimal(46) / 3.0, 0.0))
    assert(cross(
        Hailstone(rawValue: "19, 13, 30 @ -2, 1, -2")!,
        Hailstone(rawValue: "12, 31, 28 @ -1, -2, -1")!
    ) == Point3D(6.2, 19.4, 0.0))
    assert(cross(
        Hailstone(rawValue: "19, 13, 30 @ -2, 1, -2")!,
        Hailstone(rawValue: "20, 19, 15 @ 1, -5, -3")!
    ) == nil)
    assert(cross(
        Hailstone(rawValue: "18, 19, 22 @ -1, -1, -2")!,
        Hailstone(rawValue: "20, 25, 34 @ -2, -2, -4")!
    ) == nil)
    assert(cross(
        Hailstone(rawValue: "18, 19, 22 @ -1, -1, -2")!,
        Hailstone(rawValue: "12, 31, 28 @ -1, -2, -1")!
    ) == Point3D(-6, -5, 0.0))
    assert(cross(
        Hailstone(rawValue: "18, 19, 22 @ -1, -1, -2")!,
        Hailstone(rawValue: "20, 19, 15 @ 1, -5, -3")!
    ) == nil)
    assert(cross(
        Hailstone(rawValue: "20, 25, 34 @ -2, -2, -4")!,
        Hailstone(rawValue: "12, 31, 28 @ -1, -2, -1")!
    ) == Point3D(-2, 3, 0.0))
    assert(cross(
        Hailstone(rawValue: "20, 25, 34 @ -2, -2, -4")!,
        Hailstone(rawValue: "20, 19, 15 @ 1, -5, -3")!
    ) == nil)
    assert(cross(
        Hailstone(rawValue: "12, 31, 28 @ -1, -2, -1")!,
        Hailstone(rawValue: "20, 19, 15 @ 1, -5, -3")!
    ) == nil)
    
    return solution(input)
}

func b(_ input: String) -> Int {
    1
}
