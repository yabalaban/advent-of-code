import AocUtils
import Foundation

// Required for authorisation to fetch the problem statements
guard let cookie = ProcessInfo.processInfo.environment["AOC_COOKIE"] else {
    fatalError("AOC_COOKIE env variable has to be specified")
}

let aoc2023 = getProblemSet(for: 2023, cookie: cookie)

var day1 = aoc2023.problem(for: .day1)
day1.part1 = extractCalibrationNumber(from:)
day1.part2 = extractCalibrationNumberExtended(from:)

var day2 = aoc2023.problem(for: .day2)
day2.part1 = countPossibleGames(_:)
day2.part2 = calculateFitPower(_:)

var day3 = aoc2023.problem(for: .day3)
day3.part1 = parsePartNumbers(_:)
day3.part2 = parseGearsNumbers(_:)

var day4 = aoc2023.problem(for: .day4)
day4.part1 = countPoints(_:)
day4.part2 = countScratchcard(_:)

var day5 = aoc2023.problem(for: .day5)
day5.part1 = resolveAlmanac(_:)
day5.part2 = resolveAlmanacRanged(_:)

var day6 = aoc2023.problem(for: .day6)
day6.part1 = numberOfWaysToBeat(_:)
day6.part2 = numberOfWaysToBeatExtra(_:)

var day7 = aoc2023.problem(for: .day7)
day7.part1 = camelCasePoker(_:)
day7.part2 = camelCaseJokersPoker(_:)

var day8 = aoc2023.problem(for: .day8)
day8.part1 = countHops(_:)
day8.part2 = countHopsGhosts(_:)

var day9 = aoc2023.problem(for: .day9)
day9.part1 = extrapolateRight(_:)
day9.part2 = extrapolateLeft(_:)

var day10 = aoc2023.problem(for: .day10)
day10.part1 = pipesDepth(_:)
day10.part2 = pipesEnclosingTiles(_:)

var day11 = aoc2023.problem(for: .day11)
day11.part1 = totalDistance(_:)
day11.part2 = totalDistanceCoef(_:)

var day12 = aoc2023.problem(for: .day12)
day12.part1 = countArrangementsOfSprings(_:)
day12.part2 = countUnfoldedArrangementsOfSprings(_:)

var day13 = aoc2023.problem(for: .day13)
day13.part1 = getMirrorScore(_:)
day13.part2 = getMirrorScoreWithDelta(_:)

var day14 = aoc2023.problem(for: .day14)
day14.part1 = totalLoadOnNorth(_:)
day14.part2 = totalLoadOnNorthWithSpins(_:)

var day15 = aoc2023.problem(for: .day15)
day15.part1 = lensHasher(_:)
day15.part2 = lensFocusingPower(_:)

var day16 = aoc2023.problem(for: .day16)
day16.part1 = countEnergizedCells(_:)
day16.part2 = countEnergizedCellsGridSearch(_:)

var day17 = aoc2023.problem(for: .day17)
day17.part1 = minHeatLoss(_:)
day17.part2 = minHeatLossUltra(_:)

var day18 = aoc2023.problem(for: .day18)
day18.part1 = countCubicMeters(_:)
day18.part2 = countCubicMetersExtended(_:)

var day19 = aoc2023.problem(for: .day19)
day19.part1 = combineRatingNumbers(_:)
day19.part2 = distinctCombinations(_:)

var day20 = aoc2023.problem(for: .day20)
day20.part1 = countPulses(_:)
day20.part2 = countButtonTapsToRx(_:)

var day21 = aoc2023.problem(for: .day21)
day21.part1 = countGardenPlots(_:)
day21.part2 = countGardenPlotsInfinitely(_:)

var day22 = aoc2023.problem(for: .day22)
day22.part1 = countDisintegrationCandidates(_:)
day22.part2 = totalBrickToCollaps(_:)

var day23 = aoc2023.problem(for: .day23)
day23.part1 = stepsOfLongestHike(_:)
day23.part2 = stepsOfLongestHikeExtended(_:)

var day24 = aoc2023.problem(for: .day24)
day24.part1 = countIntersectionsInRange(_:)
day24.part2 = b(_:)

// Prints all available solutions
try await aoc2023.solve()
