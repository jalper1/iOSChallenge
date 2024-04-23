//
//  MealListViewUITests.swift
//  FetchChallengeTests
//
//  Created by Jordan on 4/22/24.
//

import XCTest

final class MealListViewUITests: XCTestCase {
    
    // Test the loading indicator that appears before desserts are loaded
    func testInitialLoadingIndicator() {
        let app = XCUIApplication()
        app.launch()
        
        let progressView = app.activityIndicators["Loading..."]
        XCTAssertFalse(progressView.exists, "The loading indicator should not be visible on launch.")
    }
    
    // Test the title of the navigation bar is Desserts
    func testMealListTitle() {
        let app = XCUIApplication()
        app.launch()
        
        let navigationTitle = app.navigationBars["Desserts"]
        XCTAssertTrue(navigationTitle.exists, "The navigation bar should have the title 'Desserts'.")
    }
    
    // Test navigation from MealListView to MealDetailView by tapping a meal
    func testNavigateToMealDetailView() {
        let app = XCUIApplication()
        app.launch()
        
        // determines if navigation view exists
        let navBar = app.navigationBars["Desserts"]
        XCTAssertTrue(navBar.exists, "Navigation bar should be visible")

        // Check if Apam balik exists in the list then tap it
        let firstCell = app.otherElements.buttons["Apam balik"]
        XCTAssertTrue(firstCell.exists, "First cell should exist in the list")
        firstCell.tap()
            
        // Verify the Meal Detail View appears
        let detailScrollView = app.scrollViews.firstMatch
        XCTAssertTrue(detailScrollView.waitForExistence(timeout: 5), "Meal detail view should be visible")
    }
}
