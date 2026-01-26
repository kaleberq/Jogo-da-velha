//
//  GameIntents.swift
//  tic_tac_toe
//
//  Created by Kalebe Misael on 23/01/26.
//

import AppIntents
import Foundation
import WidgetKit

private let kMaxRoundsKey = "widget_max_rounds"
private let kTimeLimitKey = "widget_time_limit"
private let kDefaultMaxRounds = 5
private let kDefaultTimeLimit = 10

// MARK: - Helper para UserDefaults
struct GameSettings {
    static var maxRounds: Int {
        get {
            let value = UserDefaults.standard.integer(forKey: kMaxRoundsKey)
            return value > 0 ? value : kDefaultMaxRounds
        }
        set {
            UserDefaults.standard.set(newValue, forKey: kMaxRoundsKey)
        }
    }
    
    static var timeLimit: Int {
        get {
            let value = UserDefaults.standard.integer(forKey: kTimeLimitKey)
            return value > 0 ? value : kDefaultTimeLimit
        }
        set {
            UserDefaults.standard.set(newValue, forKey: kTimeLimitKey)
        }
    }
}

// MARK: - App Intents

struct IncreaseRoundsIntent: AppIntent {
    static var title: LocalizedStringResource = "Aumentar Rodadas"
    
    func perform() async throws -> some IntentResult {
        let current = GameSettings.maxRounds
        if current < 20 {
            GameSettings.maxRounds = current + 1
            WidgetCenter.shared.reloadTimelines(ofKind: "tic_tac_toe")
        }
        return .result()
    }
}

struct DecreaseRoundsIntent: AppIntent {
    static var title: LocalizedStringResource = "Diminuir Rodadas"
    
    func perform() async throws -> some IntentResult {
        let current = GameSettings.maxRounds
        if current > 1 {
            GameSettings.maxRounds = current - 1
            WidgetCenter.shared.reloadTimelines(ofKind: "tic_tac_toe")
        }
        return .result()
    }
}

struct IncreaseTimeIntent: AppIntent {
    static var title: LocalizedStringResource = "Aumentar Tempo"
    
    func perform() async throws -> some IntentResult {
        let current = GameSettings.timeLimit
        if current < 60 {
            GameSettings.timeLimit = current + 1
            WidgetCenter.shared.reloadTimelines(ofKind: "tic_tac_toe")
        }
        return .result()
    }
}

struct DecreaseTimeIntent: AppIntent {
    static var title: LocalizedStringResource = "Diminuir Tempo"
    
    func perform() async throws -> some IntentResult {
        let current = GameSettings.timeLimit
        if current > 5 {
            GameSettings.timeLimit = current - 1
            WidgetCenter.shared.reloadTimelines(ofKind: "tic_tac_toe")
        }
        return .result()
    }
}

struct StartGameIntent: AppIntent {
    static var title: LocalizedStringResource = "Iniciar Jogo"
    
    func perform() async throws -> some IntentResult {
        let maxRounds = GameSettings.maxRounds
        let timeLimit = GameSettings.timeLimit
        
        // Abre o app com deep link contendo os parâmetros
        let url = URL(string: "jogodavelha://local-game?maxRounds=\(maxRounds)&timeLimit=\(timeLimit)")!
        try await url.open()
        
        return .result()
    }
}
