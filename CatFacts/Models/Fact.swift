//
//  Fact.swift
//  CatFacts
//
//  Created by Jared Warren on 1/7/20.
//  Copyright © 2020 Warren. All rights reserved.
//

import Foundation

struct Fact: Codable {
    let id: Int?
    let details: String
}

struct TopLevelGETObject: Decodable {
    let facts: [Fact]
}

struct TopLevelPOSTObject: Encodable {
    let fact: Fact
}
