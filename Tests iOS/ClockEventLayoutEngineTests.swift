//
//  ClockEventLayoutEngineTests.swift
//  Tests iOS
//

import EventKit
import XCTest
@testable import TimeDraw

final class ClockEventLayoutEngineTests: XCTestCase {

    private let calendar = Calendar.current

    func testReminderIntervalFromStartUsesFiveMinutes() throws {
        let reminder = EKReminder.mock(startHour: 10, endHour: nil, color: .yellow)
        let interval = try XCTUnwrap(ClockDrawableItem.reminderInterval(for: reminder, calendar: calendar))
        XCTAssertEqual(interval.end.timeIntervalSince(interval.start), ClockEventGeometry.reminderDuration, accuracy: 1)
    }

    func testReminderIntervalFromDueUsesFiveMinutesBefore() throws {
        let reminder = EKReminder.mock(startHour: nil, endHour: 14, color: .purple)
        let interval = try XCTUnwrap(ClockDrawableItem.reminderInterval(for: reminder, calendar: calendar))
        XCTAssertEqual(interval.end.timeIntervalSince(interval.start), ClockEventGeometry.reminderDuration, accuracy: 1)
    }

    func testReminderPrefersStartOverDue() throws {
        let reminder = EKReminder.mock(startHour: 9, endHour: 14, color: .blue)
        let interval = try XCTUnwrap(ClockDrawableItem.reminderInterval(for: reminder, calendar: calendar))
        let startHour = calendar.component(.hour, from: interval.start)
        XCTAssertEqual(startHour, 9)
    }

    func testOverlappingEventsProduceMultipleLanes() {
        let today = calendar.startOfDay(for: Date())
        let events = [
            makeTimedItems(startHour: 9, endHour: 10, colors: [.red, .blue], on: today)
        ].flatMap { $0 }

        let layout = ClockEventLayoutEngine.layout(items: events, clockWidth: 240, calendar: calendar)
        let overlapSegments = layout.arcSegments.filter { $0.ring == .am && $0.laneCount == 2 }

        XCTAssertFalse(overlapSegments.isEmpty)
        XCTAssertTrue(overlapSegments.contains(where: { $0.laneIndex == 0 }))
        XCTAssertTrue(overlapSegments.contains(where: { $0.laneIndex == 1 }))
    }

    func testNonOverlappingEventsUseSingleLane() {
        let today = calendar.startOfDay(for: Date())
        let events = [
            makeTimedItem(startHour: 8, endHour: 9, color: .red, on: today),
            makeTimedItem(startHour: 10, endHour: 11, color: .blue, on: today)
        ]

        let layout = ClockEventLayoutEngine.layout(items: events, clockWidth: 240, calendar: calendar)
        XCTAssertTrue(layout.arcSegments.allSatisfy { $0.laneCount == 1 })
        XCTAssertTrue(layout.arcSegments.allSatisfy { $0.radiusOffset == 0 })
    }

    func testOverlappingNoonCrossersProduceSeparateCrossoverSegments() {
        let today = calendar.startOfDay(for: Date())
        let events = makeTimedItems(startHour: 11, endHour: 13, colors: [.red, .blue], on: today)

        let layout = ClockEventLayoutEngine.layout(items: events, clockWidth: 240, calendar: calendar)
        XCTAssertEqual(layout.crossoverSegments.count, 2)
        XCTAssertTrue(layout.crossoverSegments.allSatisfy { $0.laneCount == 2 })
    }

    func testNoonCrosserAndAfternoonOverlapThinBothPMSegments() {
        let today = calendar.startOfDay(for: Date())
        let longCrosser = makeTimedItem(
            startHour: 10, startMinute: 45, endHour: 14, endMinute: 45, color: .red, on: today
        )
        let shortOverlap = makeTimedItem(
            startHour: 13, startMinute: 45, endHour: 14, endMinute: 45, color: .blue, on: today
        )

        let layout = ClockEventLayoutEngine.layout(
            items: [longCrosser, shortOverlap],
            clockWidth: 240,
            calendar: calendar
        )
        let baseWidth: CGFloat = 10
        let overlapSegments = layout.arcSegments.filter { segment in
            segment.ring == .pm && segment.laneCount == 2
        }

        XCTAssertEqual(overlapSegments.count, 2)
        XCTAssertTrue(overlapSegments.allSatisfy { $0.lineWidth < baseWidth })
        XCTAssertTrue(overlapSegments.contains(where: { $0.item.id == longCrosser.id }))
        XCTAssertTrue(overlapSegments.contains(where: { $0.item.id == shortOverlap.id }))

        let nonOverlapPM = layout.arcSegments.filter {
            $0.ring == .pm && $0.item.id == longCrosser.id && $0.laneCount == 1
        }
        XCTAssertFalse(nonOverlapPM.isEmpty)
        XCTAssertTrue(nonOverlapPM.allSatisfy { abs($0.lineWidth - baseWidth) < 0.01 })
    }

    func testNormalizedEndAngleForAfternoonEvent() {
        let day = calendar.startOfDay(for: Date())
        let start = ClockEventGeometry.angle(for: hourDate(11, on: day), calendar: calendar)
        let end = ClockEventGeometry.angle(for: hourDate(13, on: day), calendar: calendar)
        let normalized = ClockEventGeometry.normalizedEndAngle(startDegrees: start, endDegrees: end)
        XCTAssertGreaterThan(normalized, start)
    }

    private func hourDate(_ hour: Int, on day: Date) -> Date {
        calendar.date(byAdding: .hour, value: hour, to: day)!
    }

    private func makeTimedItem(
        startHour: Int,
        endHour: Int,
        color: UIColor,
        on day: Date,
        startMinute: Int = 0,
        endMinute: Int = 0
    ) -> ClockDrawableItem {
        let store = EKEventStore()
        let event = EKEvent(eventStore: store)
        event.startDate = day.addingTimeInterval(TimeInterval(startHour * 3600 + startMinute * 60))
        event.endDate = day.addingTimeInterval(TimeInterval(endHour * 3600 + endMinute * 60))
        let calendar = EKCalendar(for: .event, eventStore: store)
        calendar.cgColor = color.cgColor
        event.calendar = calendar
        return ClockDrawableItem.from(events: [event], reminders: []).first!
    }

    private func makeTimedItems(
        startHour: Int,
        endHour: Int,
        colors: [UIColor],
        on day: Date
    ) -> [ClockDrawableItem] {
        colors.map { makeTimedItem(startHour: startHour, endHour: endHour, color: $0, on: day) }
    }
}
