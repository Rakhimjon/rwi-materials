/// Copyright (c) 2021 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct SearchView: View {
  @ObservedObject var viewModel: SearchViewModel
  
  // For some reason, isSearching only change on subviews.
  // isSearching is also get only so we can't dismiss the searchbar after hitting submit.
//  @Environment(\.isSearching) var isSearching: Bool
  
  private let columns = [
    GridItem(.flexible()),
    GridItem(.flexible())
  ]
  
  var body: some View {
    ScrollView {
      if viewModel.animals.isEmpty {
        SuggestionsGrid(suggestions: AnimalSearchType.suggestions) { suggestion in
          viewModel.selectTypeSuggestion(suggestion)
        }
      } else {
        AnimalsGrid(animals: viewModel.animals)
      }
    }
    .navigationTitle("Find your future pet")
    .searchable(text: $viewModel.searchText)
    .onSubmit(of: .search) {
      viewModel.search()
    }
    // There's no .onCancel(of: .search) modifier to clear the view if the user canceled the search or cleared the search bar.
//    .onChange(of: viewModel.searchText) { newText in
//      if newText.isEmpty {
//        viewModel.resetSearch()
//      }
//    }
    .toolbar {
      ToolbarItem {
        filterMenu
      }
    }
  }
  
  var filterMenu: some View {
    Menu {
      Section {
        Text("Filter by age")
        Picker("Age", selection: $viewModel.ageSelection) {
          ForEach(AnimalSearchAge.allCases, id: \.self) { age in
            Text(age.rawValue.capitalized)
          }
        }
        .onChange(of: viewModel.ageSelection) { _ in
          viewModel.search()
        }
      }
      Section {
        Text("Filter by type")
        Picker("Type", selection: $viewModel.typeSelection) {
          ForEach(AnimalSearchType.allCases, id: \.self) { type in
            Text(type.rawValue.capitalized)
          }
        }
        .onChange(of: viewModel.typeSelection) { _ in
          viewModel.search()
        }
      }
    } label: {
      Label("Filter", systemImage: "slider.horizontal.3")
    }
  }
}

struct SearchView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      SearchView(
        viewModel: SearchViewModel(
          animalSearcher: AnimalSearcherMock()
        )
      )
    }
  }
}

#warning("For testing purposes")
struct AnimalSearcherMock: AnimalSearcher {
  func searchAnimal(
    by text: String,
    age: AnimalSearchAge,
    type: AnimalSearchType
  ) async -> [Animal] {
    var animals = Animal.mock
    if age != .none {
      animals = animals.filter { $0.age.rawValue.lowercased() == age.rawValue.lowercased() }
    }
    if type != .none {
      animals = animals.filter { $0.type.lowercased() == type.rawValue.lowercased() }
    }
    return animals.filter { $0.name.contains(text) }
  }
}
