//
//  MapViewActionButton.swift
//  Personal Bus Tracker
//
//  Created by jeff wong on 2022-12-30.
//

import SwiftUI

struct MapViewActionButton: View {
    @Binding var showLocationSearchView: Bool
    var body: some View {
        Button{
            withAnimation(.spring()){
                showLocationSearchView.toggle()
            }
        } label: {
            if (showLocationSearchView){
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundColor(.black)
                    .padding()
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(radius: 6)
                
            } else{
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundColor(.black)
                    .padding()
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(radius: 6)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MapViewActionButton_Previews: PreviewProvider {
    static var previews: some View {
        MapViewActionButton(showLocationSearchView: .constant(true))
    }
}
