import SwiftUI

// struct to store each meals details
struct MealDetail: Decodable {
    let mealName: String
    var ingredients: [String] = []
    let instructions: String

    // map variables to parts of the JSON object
    enum CodingKeys: String, CodingKey {
        case mealName = "strMeal"
        case instructions = "strInstructions"
    }
    // creates instance from data
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mealName = try container.decode(String.self, forKey: .mealName)
        instructions = try container.decode(String.self, forKey: .instructions)

        let baseDecoder = try decoder.singleValueContainer()
        let fullMealData = try baseDecoder.decode([String: String?].self)

        // loops through ingredients and measurements and puts them into a string
        for i in 1...20 {
            let ingredientKey = "strIngredient\(i)"
            let measurementKey = "strMeasure\(i)"

            if let ingredient = fullMealData[ingredientKey] as? String,
               let measurement = fullMealData[measurementKey] as? String,
               !ingredient.isEmpty, !measurement.isEmpty {
                ingredients.append("\(measurement) \(ingredient)")
            }
        }
    }
}

// struct to load all meal details
struct MealDetailResponse: Decodable {
    let meals: [MealDetail]
}

// loads and displays meal details
struct MealDetailView: View {
    let mealId: String // mealId parameter
    @State private var mealDetails: MealDetail? // loads the MealDetail struct
    @State private var isLoading = true // state that tracks if component is loading
    
    // displays to screen
    var body: some View {
        ScrollView {
            VStack(alignment: .leading){
                if isLoading {
                    ProgressView("Loading meal details...")
                } else if let meal = mealDetails { // if is not loading
                    VStack {
                        Text(meal.mealName) // displays meal name
                            .font(.system(size: 40))
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    }
                    // lists out the ingredients strings which contain measurement and ingredients
                    ForEach(meal.ingredients, id: \.self) { ingredient in
                         Text(ingredient)
                             .font(.headline)
                             .padding(.leading)
                     }
                    // displays out the instruction string
                    Text(meal.instructions)
                        .padding()
                } else {
                    Text("Failed to load meal details")
                }
            }
            .foregroundColor(.orange)        }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear(perform: loadMealDetail)
        }

    // loads meal details based on mealId
    private func loadMealDetail() {
        // calls the fetchMealDetails function
        fetchMealDetails(mealId: mealId) { mealDetail, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let mealDetail = mealDetail {
                    self.mealDetails = mealDetail
                } else if let error = error {
                    print("Failed to fetch meal details: \(error.localizedDescription)")
                }
            }
        }
    }

}

// loads meal details from the API based on mealId
func fetchMealDetails(mealId: String, completion: @escaping (MealDetail?, Error?) -> Void) {
    // creates URL object
    let urlString = "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(mealId)"
    guard let url = URL(string: urlString) else {
        completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        return
    }

    // decodes data and sets it to the response
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data {
            do {
                let decoder = JSONDecoder()
                let mealDetailResponse = try decoder.decode(MealDetailResponse.self, from: data)
                if let mealDetail = mealDetailResponse.meals.first {
                    completion(mealDetail, nil) // assigns repsonse to mealDetail and calls completion clause
                } else {
                    completion(nil, NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "No meal found"]))
                }
            } catch {
                completion(nil, error)
            }
        } else if let error = error {
            completion(nil, error)
        }
    }.resume() // initiates network request
}

// previews screen
#Preview {
    MealDetailView(mealId: "53049")
}
