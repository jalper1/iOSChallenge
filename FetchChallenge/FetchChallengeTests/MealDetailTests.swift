//
//  MealDetailTests.swift
//  FetchChallengeTests
//
//  Created by Jordan on 4/22/24.
//

import XCTest
@testable import FetchChallenge

final class MealDetailTests: XCTestCase {

    // Tests the response of decoding of the Meal Detail JSON
    func testMealDetailDecoding() {
        let json = """
            {
                "strMeal": "Dessert",
                "strInstructions": "Mix well.",
                "strIngredient1": "Sugar",
                "strMeasure1": "100g",
                "strIngredient2": "Flour",
                "strMeasure2": "200g",
                "strYoutube": "youtubelink",
                "strSource": "sourcelink"
            }
            """.data(using: .utf8)!

        let decoder = JSONDecoder()
            do {
                let mealDetail = try decoder.decode(MealDetail.self, from: json)
                XCTAssertEqual(mealDetail.mealName, "Dessert")
                XCTAssertEqual(mealDetail.instructions, "Mix well.")
                XCTAssertEqual(mealDetail.ingredients.count, 2)
                XCTAssertEqual(mealDetail.ingredients[0], "100g Sugar")
                XCTAssertEqual(mealDetail.ingredients[1], "200g Flour")
                XCTAssertEqual(mealDetail.youtubeLink, "youtubelink")
                XCTAssertEqual(mealDetail.sourceLink, "sourcelink")
            } catch {
                XCTFail("Failed to decode valid JSON: \(error)")
            }
        }

    // Test decoding of Meal Detail JSON with missing fields
    func testMealDetailDecodingWithMissingFields() {
        let json = """
                {
                    "strMeal": "Dessert",
                    "strInstructions": "Mix well.",
                    "strIngredient1": "Sugar",
                    "strMeasure1": "100g",
                    "strIngredient2": "Flour",
                    "strMeasure2": "200g"
                }
                """.data(using: .utf8)!

                let decoder = JSONDecoder()
                do {
                    let mealDetail = try decoder.decode(MealDetail.self, from: json)

                    XCTAssertEqual(mealDetail.mealName, "Dessert")
                    XCTAssertEqual(mealDetail.instructions, "Mix well.")
                    XCTAssertEqual(mealDetail.ingredients.count, 2)
                    XCTAssertEqual(mealDetail.ingredients[0], "100g Sugar")
                    XCTAssertEqual(mealDetail.ingredients[1], "200g Flour")
                    XCTAssertNil(mealDetail.youtubeLink)
                    XCTAssertNil(mealDetail.sourceLink)
                } catch {
                    XCTFail("Failed to decode JSON with missing fields: \(error)")
                }
            }
        
    
    // Tests valid Youtube link
    func testValidYoutubeLink() {
            let validLink = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
            let url = URL(string: validLink)
            XCTAssertNotNil(url, "YouTube URL should be valid.")
        }

    // Tests valid source link
    func testValidSourceLink() {
        let validLink = "https://example.com"
        let url = URL(string: validLink)
        XCTAssertNotNil(url, "Source URL should be valid.")
    }
    
    // Tests invalid source link
    func testInvalidSourceLink() {
        let invalidLink = ""
        let url = URL(string: invalidLink)
        XCTAssertNil(url, "Source URL should be invalid.")
    }
}
