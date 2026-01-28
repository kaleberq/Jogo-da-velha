//
//  tic_tac_toe.swift
//  tic_tac_toe
//
//  Created by Kalebe Misael on 22/01/26.
//

import WidgetKit
import SwiftUI
import AppIntents


struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), maxRounds: GameSettings.maxRounds, timeLimit: GameSettings.timeLimit)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), maxRounds: GameSettings.maxRounds, timeLimit: GameSettings.timeLimit)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = SimpleEntry(date: Date(), maxRounds: GameSettings.maxRounds, timeLimit: GameSettings.timeLimit)
        let timeline = Timeline(entries: [entry], policy: .after(Calendar.current.date(byAdding: .minute, value: 1, to: Date())!))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let maxRounds: Int
    let timeLimit: Int
}

struct tic_tac_toeEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 8) {
            Text("Jogo da Velha")
                .font(.headline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                Text("Rodadas:")
                    .font(.subheadline)
                Spacer()
               
                    Button(intent: DecreaseRoundsIntent()) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(entry.maxRounds > 1 ? .blue : .gray)
                    }
                    .disabled(entry.maxRounds <= 1)
                    
                    Text("\(entry.maxRounds)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(minWidth: 30)
                    
                    Button(intent: IncreaseRoundsIntent()) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(entry.maxRounds < 20 ? .blue : .gray)
                    }
                    .disabled(entry.maxRounds >= 20)
                
            }
            HStack {
                Text("Tempo:")
                    .font(.subheadline)
                Spacer()
                    Button(intent: DecreaseTimeIntent()) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(entry.timeLimit > 5 ? .blue : .gray)
                    }
                    .disabled(entry.timeLimit <= 5)
                    
                    Text("\(entry.timeLimit)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(minWidth: 30)
                    
                    Button(intent: IncreaseTimeIntent()) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(entry.timeLimit < 60 ? .blue : .gray)
                    }
                    .disabled(entry.timeLimit >= 60)
                
            }
                Link(destination: URL(string: "jogodavelha://local-game?maxRounds=\(entry.maxRounds)&timeLimitSeconds=\(entry.timeLimit)")!) {
                    
                    Text("Iniciar Jogo")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
                
            }
        }
        .padding()
    }
}

struct tic_tac_toe: Widget {
    let kind: String = "tic_tac_toe"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                tic_tac_toeEntryView(entry: entry).containerBackground(.fill.tertiary, for: .widget)
            } else {
                tic_tac_toeEntryView(entry: entry).padding().background()
            }
        }
        .configurationDisplayName("Jogo da Velha")
        .description("Configure e inicie o jogo diretamente do widget.").supportedFamilies([.systemMedium])
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview(as: .systemMedium) {
    tic_tac_toe()
} timeline: {
    SimpleEntry(date: Date(), maxRounds: 5, timeLimit: 10)
}
#endif
