//
//  MealListTests.swift
//  FetchChallengeTests
//
//  Created by Jordan on 4/22/24.
//

import XCTest
@testable import FetchChallenge

final class MealListTests: XCTestCase {
    
    // Test the decoding of a valid JSON response
    func testFetchMealsValidResponse() {
        let json = """
        {
            "meals": [
                {
                    "strMeal": "Dessert One",
                    "strMealThumb": "https://example.com/image1.jpg",
                    "idMeal": "12345"
                },
                {
                    "strMeal": "Dessert Two",
                    "strMealThumb": "https://example.com/image2.jpg",
                    "idMeal": "67890"
                }
            ]
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        do {
            let mealResponse = try decoder.decode(MealResponse.self, from: json)
            XCTAssertEqual(mealResponse.meals.count, 2)
            XCTAssertEqual(mealResponse.meals[0].strMeal, "Dessert One")
            XCTAssertEqual(mealResponse.meals[1].strMeal, "Dessert Two")
        } catch {
            XCTFail("Failed to decode the valid JSON")
        }
    }
    
    // Test the response when attempting to decode invalid JSON
    func testFetchMealsInvalidResponse() {
        let invalidJson = "invalid json".data(using: .utf8)!
        
        let decoder = JSONDecoder()
        XCTAssertThrowsError(try decoder.decode(MealResponse.self, from: invalidJson))
    }
    
    // Test the behavior when the JSON contains meals with null or empty values
    func testFetchMealsWithNullValues() {
        let json = """
        {
            "meals": [
                {
                    "strMeal": "",
                    "strMealThumb": "https://example.com/image1.jpg",
                    "idMeal": "12345"
                },
                {
                    "strMeal": "Dessert Two",
                    "strMealThumb": "",
                    "idMeal": "67890"
                }
            ]
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        do {
            let mealResponse = try decoder.decode(MealResponse.self, from: json)
            let filteredMeals = mealResponse.meals.filter { !($0.strMeal.isEmpty || $0.strMealThumb.isEmpty || $0.idMeal.isEmpty) }
            XCTAssertEqual(filteredMeals.count, 0)
        } catch {
            XCTFail("Failed to decode the valid JSON")
        }
    }
}
