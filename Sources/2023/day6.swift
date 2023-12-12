import Foundation

func solution(_ time: Double, _ distance: Double) -> Int {
    // (time - x) * x = distance
    // time * x - x * x - distance = 0
    // -x * x + time * x - distsance = 0
    //
    // x^2 - time * x + distance = 0
    let d = sqrt(time * time - 4.0 * distance)
    let s1 = (-time - d) / -2.0
    let s2 = (-time + d) / -2.0
    let ub = ceil(s1) - 1
    let lb = floor(s2) + 1
    return Int(ub - lb) + 1
}

func numberOfWaysToBeat(_ input: String) -> Int {
    { // assertions
        assert(solution(7, 9) == 4)
        assert(solution(15, 40) == 8)
        assert(solution(30, 200) == 9)
    }()

    let lines = input.split(separator: "\n")
    let times = lines.first!.split(separator: ":").last!.split(separator: " ").compactMap({ Double($0) })
    let distances = lines.last!.split(separator: ":").last!.split(separator: " ").compactMap({ Double($0) })
    return zip(times, distances).map(solution).reduce(1, *)
}

func numberOfWaysToBeatExtra(_ input: String) -> Int {
    { // assertions
        assert(solution(71530, 940200) == 71503)
    }()
    return solution(40828492, 233101111101487)
}

