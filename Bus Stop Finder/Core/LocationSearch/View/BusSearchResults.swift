//
//  BusSearchResults.swift
//  Bus Stop Finder
//
//  Created by jeff wong on 2023-01-27.
//

import SwiftUI

struct BusSearchResultCell: View {
    var BusStop: BusStopModel
    var body: some View {
        HStack{
            Image(systemName: "mappin.circle.fill")
                .resizable()
                .foregroundColor(.blue)
                .accentColor(.white)
                .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 4){
                Text("Bus Stop: " + BusStop.Routes)
                    .font(.body)
                Text(BusStop.Name)
                    .font(.system(size:15))
                    .foregroundColor(.gray)
                Divider()
            }
            .padding(.leading, 8)
        }
        .padding(.leading)
        .padding(.vertical, 8)
    }
}
