//
//  Grade.swift
//  HTWDD
//
//  Created by Benjamin Herzog on 04/01/2017.
//  Copyright © 2017 HTW Dresden. All rights reserved.
//

import Foundation
import RxSwift
import Marshal

struct Grade: Identifiable {

    let nr: Int
    let state: String
    let credits: Double
    let text: String
    let semester: Semester
    let numberOfTry: Int
    let date: Date?
    let mark: Double?
    let note: String?

    static func get(network: Network, course: Course) -> Observable<[Grade]> {
        let parameters = [
            "POVersion": "\(course.POVersion)",
            "AbschlNr": course.abschlNr,
            "StgNr": course.stgNr
        ]

        return network.getArray(url: Grade.url, params: parameters)
    }

}

extension Grade: Unmarshaling {
    static let url = "https://wwwqis.htw-dresden.de/appservice/v2/getgrades"

    init(object: MarshaledObject) throws {
        self.nr = try object <| "nr"
        self.state = try object <| "state"
        self.credits = try object <| "credits"
        self.text = try object <| "text"
        self.semester = try object <| "semester"
        self.numberOfTry = try object <| "tries"

        let dateRaw: String? = try object <| "examDate"
        self.date = try dateRaw.map {
             try Date.from(string: $0, format: "yyyy-MM-dd'T'HH:mmZ")
        }

        let markRaw: Double? = try object <| "grade"
        self.mark = markRaw.map { $0 / 100 }

        self.note = try? object <| "note"
    }

}

extension Grade: Equatable {

    static func ==(lhs: Grade, rhs: Grade) -> Bool {
        return lhs.nr == rhs.nr
            && lhs.mark == rhs.mark
            && lhs.credits == rhs.credits
            && lhs.semester == rhs.semester
    }

}