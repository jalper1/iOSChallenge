//
//  MealDetailViewUITests.swift
//  FetchChallengeTests
//
//  Created by Jordan on 4/22/24.
//

import XCTest

final class MealDetailViewUITests: XCTestCase {
    
    // Test that the loading indicator works before desserts are loaded
    func testInitialLoadingIndicator() {
        let app = XCUIApplication()
        app.launch()
        
        let progressView = app.activityIndicators["Loading..."]
        XCTAssertFalse(progressView.exists, "The loading indicator should not be visible on launch.")
    }
    
    // Test MealDetailView page elements
    func testNavigateToMealDetailView() {
        let app = XCUIApplication()
        app.launch()

        // Tap the Apam balik item in the list
        let firstCell = app.otherElements.buttons["Apam balik"]
        firstCell.tap()
            
        // Verify the Meal Detail View appears
        let detailScrollView = app.scrollViews.firstMatch
        XCTAssertTrue(detailScrollView.waitForExistence(timeout: 5), "Meal detail view should be visible")

        // Check if a meal name is present in the Meal Detail View
        let mealNameText = detailScrollView.staticTexts.element(boundBy: 0)
        XCTAssertTrue(mealNameText.exists, "Meal name should be visible in the detail view")
        
        // Check if measurements/ingredients are present in the Meal Detail View
        let mealIngredientText = detailScrollView.staticTexts.element(boundBy: 1)
        XCTAssertTrue(mealIngredientText.exists, "Meal measurements/ingredients should be visible in the detail view")
        
        // Check if instructions are present in the Meal Detail View
        let mealInstructionText = detailScrollView.staticTexts.element(boundBy: 2)
        XCTAssertTrue(mealInstructionText.exists, "Meal instructions should be visible in the detail view")
    }
}
