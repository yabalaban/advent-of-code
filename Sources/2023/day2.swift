class Game {
    struct Configuration {
        var red: Int
        var green: Int
        var blue: Int
    }
    
    let config: Configuration
    
    init(config: Configuration) {
        self.config = config
    }
    
    func isPossible(_ move: String) -> Int? {
        let state = move.split(separator: ":")
        let possible = state.last?
            .split(separator: ";")
            .allSatisfy({ set in
                set.split(separator: ",").allSatisfy { cubes in
                    let i = cubes.split(separator: " ")
                    let value = Int(i.first!)!
                    let cube = i.last!
                    if cube == "red" {
                        return self.config.red >= value
                    } else if cube == "green" {
                        return self.config.green >= value
                    } else if cube == "blue" {
                        return self.config.blue >= value
                    } else {
                        return false
                    }
                }
            }) ?? false
        let id = state.first?.split(separator: " ").last!
        return if possible { Int(id!)! } else { nil }
    }
    
    static func getFitConfigurationPower(_ move: String) -> Int {
        var config = Configuration(red: 0, green: 0, blue: 0)
        _ = move.split(separator: ":").last?
            .split(separator: ";")
            .map({ set in
                set.split(separator: ",").map { cubes in
                    let i = cubes.split(separator: " ")
                    let value = Int(i.first!)!
                    let cube = i.last!
                    if cube == "red" {
                        config.red = max(value, config.red)
                    } else if cube == "green" {
                        config.green = max(value, config.green)
                    } else if cube == "blue" {
                        config.blue = max(value, config.blue)
                    }
                }
            })
        return config.red * config.green * config.blue
    }
}

func countPossibleGames(_ input: String) -> Int {
    let game = Game(config: Game.Configuration(red: 12, green: 13, blue: 14))
    _ = { // assertions
        assert(game.isPossible("Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green") == 1)
        assert(game.isPossible("Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue") == 2)
        assert(game.isPossible("Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red") == nil)
        assert(game.isPossible("Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red") == nil)
        assert(game.isPossible("Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green") == 5)
    }()
    return input.split(separator: "\n")
        .map(String.init)
        .compactMap({ game.isPossible($0) })
        .reduce(0, +)
}

func calculateFitPower(_ input: String) -> Int {
    _ = { // assertions
        assert(Game.getFitConfigurationPower("Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green") == 48)
        assert(Game.getFitConfigurationPower("Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue") == 12)
        assert(Game.getFitConfigurationPower("Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red") == 1560)
        assert(Game.getFitConfigurationPower("Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red") == 630)
        assert(Game.getFitConfigurationPower("Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green") == 36)
    }()
    return input.split(separator: "\n")
        .map(String.init)
        .compactMap({ Game.getFitConfigurationPower($0) })
        .reduce(0, +)
}
