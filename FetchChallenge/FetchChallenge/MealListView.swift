import SwiftUI

// struct to record the meal name, thumbnail, and id
struct Meal: Decodable {
    let strMeal: String
    let strMealThumb: String
    let idMeal: String
}

// struct to store the loaded meals
struct MealResponse: Decodable {
    let meals: [Meal]
}

// loads and displays meals
struct MealListView: View {
    @State var meals: [Meal] = []  // Variable to store the fetched meals
    @State var isLoading = true    // State to track data loading

    var body: some View {
        NavigationView { // allows for clickable links for each dessert
            // lists each dessert, their name, and their thumbnail image as a clickable NavLink
            List(meals, id: \.idMeal) { meal in
                NavigationLink(destination: MealDetailView(mealId: meal.idMeal)) {
                    HStack{
                        if let imageUrl = URL(string: meal.strMealThumb) {
                            AsyncImage(url: imageUrl) { image in // displays the thumbnail image
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                    .accessibilityLabel(meal.strMeal)
                            } placeholder: {
                                ProgressView() // adds a placeholder loading symbol for when the image has not fully loaded in
                            }
                        }
                        Text(meal.strMeal) // displays the name of the meal
                            .font(.system(size: 24))
                            .padding(.leading)
                    }
                }
                .accessibility(identifier: meal.strMeal)
                .foregroundColor(Color.orange)

            }
            .navigationTitle("Desserts") // adds a title to the Navigation Page
            .onAppear(perform: loadMeals) // calls the loadMeals function on page start
            .overlay {
                if isLoading {
                    ProgressView("Loading...") // if the page is loading it shows this
                }
            }
        }
    }

    // function to load the meals
    func loadMeals() {
        // calls the fetchMeals function
        fetchMeals { fetchedMeals, error in
            if let fetchedMeals = fetchedMeals { // checks whether the meals have loaded
                self.meals = fetchedMeals
                self.isLoading = false
            } else {
                // prints an error if the meals did not load
                print("Error occurred: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}

// function to fetch the meals from the API
func fetchMeals(completion: @escaping ([Meal]?, Error?) -> Void) {
    // attempts to make a URL object, if it fails it exits with an error
    guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/filter.php?c=Dessert") else {
        completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        return
    }

    // task created with URL to send HTTP request
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data {
            do {
                // decode data from JSON into MealResponse object
                let decoder = JSONDecoder()
                let mealResponse = try decoder.decode(MealResponse.self, from: data)
                
                // Filter out meals with null or empty values
                let filteredMeals = mealResponse.meals.filter { meal in
                    return !meal.strMeal.isEmpty && !meal.strMealThumb.isEmpty && !meal.idMeal.isEmpty
                }
                // run the completion
                DispatchQueue.main.async {
                    completion(filteredMeals, nil)
                }
            } catch {
                // if error, run completion with nil
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        } else if let error = error {
            DispatchQueue.main.async {
                completion(nil, error)
            }
        }
    }.resume() // initiates network request
}

// previews the screen
#Preview {
    MealListView()
}
