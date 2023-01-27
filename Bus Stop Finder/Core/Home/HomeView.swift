//
//  HomeView.swift
//  Bus Stop Finder
//
//  Created by jeff wong on 2022-12-29.
//

import SwiftUI
import MapKit

struct HomeView: View {
    @State private var showLocationSearchView = false
    @State var isAnnotationSelected = false
    @State var selectedAnnotation = MKPointAnnotation()
    @State var BusStopResults = [BusStopModel]()
    
    var body: some View {
        VStack{
            ZStack (alignment: .top){
                BusMapViewRepresentable(results: $BusStopResults, isAnnotationSelected: $isAnnotationSelected, selectedAnnotation: $selectedAnnotation)
                    .ignoresSafeArea()
                
                if showLocationSearchView{
                    LocationSearchView(BusStopResults: $BusStopResults, isAnnotationSelected: $isAnnotationSelected, selectedAnnotation: $selectedAnnotation)
                } else{
                    LocationSearchActivationView()
                        .padding(.vertical, 72)
                        .onTapGesture {
                            withAnimation(.spring()){
                                showLocationSearchView.toggle()
                            }
                        }
                }
                MapViewActionButton(showLocationSearchView: $showLocationSearchView)
                    .padding(.leading)
                    .padding(.top,4)
                
            }
            if isAnnotationSelected{
                BusStopPopUp(isAnnotationSelected: $isAnnotationSelected, selectedAnnotation: $selectedAnnotation)
                    .ignoresSafeArea()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
