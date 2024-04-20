import SwiftUI

struct Meal: Decodable {
    let strMeal: String
    let strMealThumb: String
    let idMeal: String
}

struct MealListView: View {
    @State private var meals: [Meal] = []  // Variable to store the fetched meals
    @State private var isLoading = true    // State to track data loading

    var body: some View {
        NavigationView {
            List(meals, id: \.idMeal) { meal in
                NavigationLink(destination: MealDetailView(mealId: meal.idMeal)) {
                    if let imageUrl = URL(string: meal.strMealThumb) {
                        AsyncImage(url: imageUrl) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    Text(meal.strMeal)
                }
            }
            .navigationTitle("Desserts")
            .onAppear(perform: loadMeals)
            .overlay {
                if isLoading {
                    ProgressView("Loading...")
                }
            }
        }
    }

    func loadMeals() {
        fetchMeals { fetchedMeals, error in
            if let fetchedMeals = fetchedMeals {
                self.meals = fetchedMeals
                self.isLoading = false
            } else {
                print("Error occurred: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}

func fetchMeals(completion: @escaping ([Meal]?, Error?) -> Void) {
    guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/filter.php?c=Dessert") else {
        completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        return
    }

    URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data {
            do {
                let decoder = JSONDecoder()
                let mealResponse = try decoder.decode(MealResponse.self, from: data)
                
                // Filter out meals with null or empty values
                let filteredMeals = mealResponse.meals.filter { meal in
                    return !meal.strMeal.isEmpty && !meal.strMealThumb.isEmpty && !meal.idMeal.isEmpty
                }
                
                DispatchQueue.main.async {
                    completion(filteredMeals, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        } else if let error = error {
            DispatchQueue.main.async {
                completion(nil, error)
            }
        }
    }.resume()
}

struct MealResponse: Decodable {
    let meals: [Meal]
}

#Preview {
    MealListView()
}
