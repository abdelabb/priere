//
//  PrayerView.swift
//  PriereSwuiftUI
//
//  Created by abbas on 11/05/2024.
//

import SwiftUI
import Foundation

struct CoranView: View {
    @StateObject private var viewModel = QuranViewModel()
    @State private var showingSurahSelection = false
    
    
    var body: some View {
  
       

        VStack {
        
              
                        Button(action: {
                            showingSurahSelection = true
                        })  {
                            if let selectedSurah = viewModel.selectedSurah {
                                
                                Text("Select Sourah")
                                    
                                
                            }
                
                        }.sheet(isPresented: $showingSurahSelection) {
                            SurahSelectionView(viewModel: viewModel)
                            
                        }
                       // .buttonStyle(.bordered)
                        //.tint(.green)
                  
            NavigationView{

                if let selectedSurah = viewModel.selectedSurah {
                    
                    
                    List(viewModel.verses) { verse in
                   
                            
                            
                            Text(verse.textUthmani)
                                .font(.system(size: 20))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .listRowSeparator(.hidden)

                        
                        .padding()
                        
                        
                    }
                    .navigationTitle(viewModel.selectedSurah?.englishName ?? "")

                   
                    

                    
                }else {
                    Text("Loading...")
                }

            }
            //.navigationBarHidden(true)

            
        }
 

             
    
            //.background(ignoresSafeAreaEdges: .all)

                .onAppear {
                    if viewModel.selectedSurah == nil {
                        viewModel.fetchSurah()
                    }
            }

    }
}



struct SurahSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: QuranViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.surahs) { surah in
                Button(action: {
                    viewModel.selectedSurah = surah
                    presentationMode.wrappedValue.dismiss()
                }) {
                    VStack(alignment: .leading) {
                        Text(surah.name)
                            .font(.headline)
                        Text(surah.englishName)
                            .font(.subheadline)
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Select Surah")
        }
    }
}

struct QuranVersesResponse: Codable {
    let verses: [Ayah]
}

struct QuranData: Codable {
    let surah: Surah
}

struct Surah: Codable,Identifiable {
    let id: Int
    let name: String
    let englishName: String
    let englishNameTranslation: String
    let numberOfAyahs: Int
    let revelationType: String
    
    enum CodingKeys: String, CodingKey {
        case id = "number"
        case name
        case englishName
        case englishNameTranslation
        case numberOfAyahs
        case revelationType
    }
}

struct Ayah: Codable, Identifiable {
    let id: Int
    let verseKey: String
    let textUthmani: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case verseKey = "verse_key"
        case textUthmani = "text_uthmani"
    }
}

struct Translation: Codable {
    let text: String
}
struct SurahListResponse: Codable {
    let data: [Surah]
}

class QuranViewModel: ObservableObject {
    @Published var verses: [Ayah] = []
    @Published var surahs: [Surah] = []
    @Published var selectedSurah: Surah?{
        didSet{
            if let selectedSurah = selectedSurah{
                fetchVerses(surahNumber: selectedSurah.id)
            }
        }
    }
    init() {
        fetchSurah()
    }
    
    func fetchSurah(){
        guard let url = URL(string: "https://api.alquran.cloud/v1/surah") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(SurahListResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.surahs = decodedResponse.data
                        self.selectedSurah = self.surahs.first
                        
                    }
                } catch {
                    print("Failed to decode JSON: \(error)")
                }
            } else if let error = error {
                print("Network error: \(error.localizedDescription)")
            }
        }.resume()
        
    }
    
    func fetchVerses(surahNumber: Int) {
        guard let url = URL(string: "https://api.quran.com/api/v4/quran/verses/uthmani?chapter_number=\(surahNumber)") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(QuranVersesResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.verses = decodedResponse.verses
                    }
                } catch {
                    print("Failed to decode JSON: \(error)")
                }
            }
        }.resume()
    }
}



#Preview {
    CoranView()
}
