//
//  WidgetDemoExt.swift
//  WidgetDemoExt
//
//  Created by Nitin Bhatia on 29/11/22.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DayEntry {
        DayEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (DayEntry) -> ()) {
        let entry = DayEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [DayEntry] = []

        // Generate a timeline consisting of seven entries an day apart, starting from the current date.
        let currentDate = Date()
        for dayOffset in 0 ..< 7 {
            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
            let startOfDate = Calendar.current.startOfDay(for: entryDate)
            let entry = DayEntry(date: startOfDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct DayEntry: TimelineEntry {
    let date: Date
}

struct WidgetDemoExtEntryView : View {
    var entry: Provider.Entry
    var config : MonthConfig
    
    init(entry: DayEntry) {
        self.entry = entry
        self.config = MonthConfig.determineConfig(from: entry.date)
    }
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(config.backgroundColor.gradient)
            
            VStack {
                HStack(spacing: 4) {
                    Text(config.emojiText)
                        .font(.title)
                    Text(entry.date.weekDayDisplayFormat)
                        .font(.title3)
                        .fontWeight(.bold)
                        .minimumScaleFactor(0.6)
                        .foregroundColor(config.weekdayTextColor)
                    Spacer()

                }
                Text(entry.date.dayDispayFormat)
                    .font(.system(size: 80,weight: .heavy))
                    .foregroundColor(config.dayTextColor)
            }
            .padding()
        }
    }
}

struct WidgetDemoExt: Widget {
    let kind: String = "MonthlyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetDemoExtEntryView(entry: entry)
        }
        .configurationDisplayName("Monthly Style Widget")
        .description("The theme of the widget changes based on month.")
        .supportedFamilies([.systemSmall]) //if you dont have many info to display then don't support other large display families
    }
}

struct WidgetDemoExt_Previews: PreviewProvider {
    static var previews: some View {
//        WidgetDemoExtEntryView(entry: DayEntry(date: Date()))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        WidgetDemoExtEntryView(entry: DayEntry(date: dateToDisplay(month: 12, day: 25)))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
    
    static func dateToDisplay(month: Int, day:Int) -> Date {
        let components = DateComponents(calendar: Calendar.current, year: Calendar.current.component(.year, from: Date()),month: month,day: day)
        return Calendar.current.date(from: components)!
    }
}

extension Date {
    var weekDayDisplayFormat: String {
        self.formatted(.dateTime.weekday(.wide))
    }
    
    var dayDispayFormat: String {
        self.formatted(.dateTime.day())
    }
}
