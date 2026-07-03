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

    func testOverlappingNoonCrossersProduceGradientCrossoverSegment() {
        let today = calendar.startOfDay(for: Date())
        let events = makeTimedItems(startHour: 11, endHour: 13, colors: [.red, .blue], on: today)

        let layout = ClockEventLayoutEngine.layout(items: events, clockWidth: 240, calendar: calendar)
        let gradientCrossovers = layout.crossoverSegments.filter { $0.colors.count > 1 }
        XCTAssertFalse(gradientCrossovers.isEmpty)
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
        on day: Date
    ) -> ClockDrawableItem {
        let event = EKEvent.mock(startHour: startHour, endHour: endHour, color: color)
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
