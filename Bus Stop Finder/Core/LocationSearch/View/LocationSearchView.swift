//
//  LocationSearchView.swift
//  Bus Stop Finder
//
//  Created by jeff wong on 2023-01-27.
//

import SwiftUI
import MapKit

struct LocationSearchView: View {
    @State private var BusStopText = ""
    @State private var isTapped = false
    @Binding var BusStopResults: [BusStopModel]
    @Binding var isAnnotationSelected: Bool
    @Binding var selectedAnnotation: MKPointAnnotation
    
    var body: some View {
        VStack{
            Spacer()
                .frame(minHeight: 50, maxHeight: 50)
            NavigationStack{
                VStack{
                    Text("Find your Bus Stop")
                        .font(.title.weight(.bold))
                    Text("Start looking for your bus stop by typing in the bus route.")
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(.gray)
            }
            .searchable(text: $BusStopText){
                ForEach(0..<searchResults.count, id: \.self){
                    i in
                    BusSearchResultCell(BusStop: searchResults[i])
                        .onTapGesture {
                            let anno = MKPointAnnotation()
                            anno.title = String(searchResults[i].Routes)
                            anno.subtitle = String(searchResults[i].StopNo)
                            selectedAnnotation = anno
                            isAnnotationSelected = true
                        }
                }
            }
        }
        .background(.white)
    }
    
    /// Produce the altered BusStopResult list based on if the BusStopModel's Routes contain the submitted BusStopText
    ///
    /// - Returns: A list of BusStopModels
    var searchResults: [BusStopModel] {
        if !BusStopText.isEmpty {
            return BusStopResults.filter { $0.Routes.contains(BusStopText) }
        } else{
            return BusStopResults
        }
    }
}
