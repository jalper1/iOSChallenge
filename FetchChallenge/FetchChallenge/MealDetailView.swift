import SwiftUI

struct MealDetail: Decodable {
    let mealName: String
    var ingredients: [String] = []
    let instructions: String

    enum CodingKeys: String, CodingKey {
        case mealName = "strMeal"
        case instructions = "strInstructions"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mealName = try container.decode(String.self, forKey: .mealName)
        instructions = try container.decode(String.self, forKey: .instructions)

        let baseDecoder = try decoder.singleValueContainer()
        let fullMealData = try baseDecoder.decode([String: String?].self)

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

struct MealDetailView: View {
    let mealId: String
    @State private var mealDetails: MealDetail?
    @State private var isLoading = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading){
                if isLoading {
                    ProgressView("Loading meal details...")
                } else if let meal = mealDetails {
                    Text(meal.mealName)
                        .font(.system(size: 40))
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .padding()
                    ForEach(meal.ingredients, id: \.self) { ingredient in
                         Text(ingredient)
                             .font(.headline)
                             .padding(.leading)
                     }
                    Text(meal.instructions)
                        .padding()
                } else {
                    Text("Failed to load meal details")
                }
            }
        }
            .onAppear(perform: loadMealDetail)
        }

    private func loadMealDetail() {
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

func fetchMealDetails(mealId: String, completion: @escaping (MealDetail?, Error?) -> Void) {
    let urlString = "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(mealId)"
    guard let url = URL(string: urlString) else {
        completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        return
    }

    URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data {
            do {
                let decoder = JSONDecoder()
                let mealDetailResponse = try decoder.decode(MealDetailResponse.self, from: data)
                if let mealDetail = mealDetailResponse.meals.first {
                    completion(mealDetail, nil)
                } else {
                    completion(nil, NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "No meal found"]))
                }
            } catch {
                completion(nil, error)
            }
        } else if let error = error {
            completion(nil, error)
        }
    }.resume()
}

struct MealDetailResponse: Decodable {
    let meals: [MealDetail]
}

#Preview {
    MealDetailView(mealId: "53049")
}
