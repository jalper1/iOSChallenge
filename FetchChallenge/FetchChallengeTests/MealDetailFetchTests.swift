//
//  MealDetailFetchingTests.swift
//  FetchChallengeTests
//
//  Created by Jordan on 4/22/24.
//

import XCTest
@testable import FetchChallenge

final class FetchMealDetailsTests: XCTestCase {
    
    class MockURLSessionDataTask: URLSessionDataTask {
        var resumeCalled = false
        
        override func resume() {
            resumeCalled = true
        }
    }

    class MockURLSession: URLSession {
        var nextDataTask = MockURLSessionDataTask()
        var lastURL: URL?

        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            lastURL = url
            return nextDataTask
        }
    }
        var mockSession: MockURLSession!
        
        override func setUp() {
            super.setUp()
            mockSession = MockURLSession()
        }
        
        func testFetchMealDetailsValid() {
            let expectedData = """
            {
                "meals": [
                    {
                        "strMeal": "Dessert",
                        "strInstructions": "Mix well.",
                        "strIngredient1": "Sugar",
                        "strMeasure1": "100g",
                        "strIngredient2": "Flour",
                        "strMeasure2": "200g"
                    }
                ]
            }
            """.data(using: .utf8)

            mockSession.nextDataTask = MockURLSessionDataTask()
            
            let expectation = self.expectation(description: "Completion handler invoked")
            var fetchedMeal: MealDetail?
            var fetchError: Error?
            
            fetchMealDetails(mealId: "53049", session: mockSession) { mealDetail, error in
                fetchedMeal = mealDetail
                fetchError = error
                expectation.fulfill()
            }
            
            waitForExpectations(timeout: 5, handler: nil)
            
            XCTAssertNotNil(fetchedMeal, "Meal detail should be fetched")
            XCTAssertEqual(fetchedMeal?.mealName, "Dessert")
            XCTAssertNil(fetchError, "No error should occur")
        }

        func testFetchMealDetailsInvalid() {
            let expectedData = "Invalid JSON".data(using: .utf8)
            mockSession.nextDataTask = MockURLSessionDataTask()
            
            let expectation = self.expectation(description: "Completion handler invoked")
            var fetchedMeal: MealDetail?
            var fetchError: Error?
            
            fetchMealDetails(mealId: "53049", session: mockSession) { mealDetail, error in
                fetchedMeal = mealDetail
                fetchError = error
                expectation.fulfill()
            }
            
            waitForExpectations(timeout: 5, handler: nil)
            
            XCTAssertNil(fetchedMeal, "Invalid JSON should not return a valid meal detail")
            XCTAssertNotNil(fetchError, "An error should occur when decoding invalid JSON")
        }
    }



