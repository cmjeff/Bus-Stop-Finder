//
//  BusPopUp.swift
//  Bus Stop Finder
//
//  Created by jeff wong on 2023-01-27.
//

import SwiftUI
import MapKit

struct BusStopPopUp: View {
    @Binding var isAnnotationSelected: Bool
    @Binding var selectedAnnotation: MKPointAnnotation
    @State private var BusTimes: String = ""
    
    var body: some View {
        VStack (spacing: .zero) {
            icon
            title
            content
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 40)
        .multilineTextAlignment(.center)
        .background(background)
        .overlay(alignment: .topTrailing){
            close
        }
    }
}

private extension BusStopPopUp {
    var icon: some View {
        Image (systemName: "info")
            .symbolVariant(.circle.fill)
            .font (.system(size: 50,
                           weight: .bold,
                           design: .rounded)
            )
            .foregroundStyle(.blue)
    }
    
    var title: some View {
        Text (selectedAnnotation.subtitle! + ": " + selectedAnnotation.title!)
            .font (
                .system(size: 30,
                        weight: .bold,
                        design: .rounded)
            )
            .padding ()
    }
    
    var content: some View {
        Text(BusTimes)
            .onAppear {
                splitBusRoutes() {result in
                    self.BusTimes = result
                }
            }
            .onChange(of: selectedAnnotation.subtitle, perform: { _ in
                splitBusRoutes() {result in
                    self.BusTimes = result
                }
            })
            .font (.callout)
            .foregroundColor(.black.opacity(0.8))
    }
    
    var background: some View{
        RoundedCorners(color: .white, tl: 10, tr: 10, bl:0, br: 0)
            .shadow(color: .black.opacity(0.2), radius: 3)
    }
    
    var close: some View{
        Button{
            withAnimation{
                isAnnotationSelected = false
            }
        }label: {
            Image(systemName: "xmark")
                .symbolVariant(.circle.fill)
                .font(.system(size:35,
                              weight: .bold,
                              design: .rounded)
                )
                .foregroundStyle(.gray.opacity(0.4))
                .padding(8)
        }
    }
    
    //MARK: Helpers
    
    /// Produces a time schedule string based on the Routes of the selectedAnnotation. It iterates through every route and calls the createBusTimes functions for each.
    /// When the iteration is finished, it produces the string with the bus time schedules.
    ///
    /// > Warning: Because after mutiple calls to createBusTimes causes the order of the Bus Stop Times to be altered, this fucntions uses the number of routes to
    /// > keep track of the final iteration. It also takes account for routes that may share the same route number but have different route names (shorter routes).
    ///
    /// - Returns: Upon completion, returns the complete string with the Bus Stop number and Times
    func splitBusRoutes(completion: @escaping (String)-> Void){
        var text = ""
        if (isAnnotationSelected){
            let listOfRoutes = selectedAnnotation.title!.components(separatedBy: ", ")
            var stopCount = 0
            var firstStop = true
            for route in listOfRoutes{
                createBusStopTimes(routeNum: route){ results in
                    if let fetchedData = results {
                        text += " [" + route + "] "
                        if (fetchedData.isEmpty){
                            text += "No Schedule Found"
                            stopCount+=1
                        } else{
                            var currentDestination = fetchedData[0].Schedules[0].Destination
                            for schedule in fetchedData[0].Schedules{
                                if (!schedule.CancelledStop){
                                    var leaveTime = schedule.ExpectedLeaveTime
                                    if (leaveTime.count > 9){
                                        leaveTime = String(leaveTime.dropLast(11))
                                    }
                                    if (schedule.Destination != currentDestination){
                                        text += "\n [" + route + "] " + schedule.Destination + ": " + leaveTime
                                        currentDestination = schedule.Destination
                                    } else{
                                        if (firstStop){
                                            text += schedule.Destination + ": " + leaveTime
                                        } else{
                                            text += ", " + leaveTime
                                        }
                                    }
                                    firstStop = false;
                                }
                            }
                            firstStop = true
                            stopCount += 1
                        }
                    }
                    text += "\n"
                    if (stopCount == listOfRoutes.count){
                        completion(text)
                    }
                }
            }
        }
    }
    
    
    /// Using Translink's own Real-time Transit Information, this functions uses the selectedAnnotion's subtitle (which contains the bus stop number) and the given
    /// route number to create a http get call. Then it recieves an JSON response object that gets decoded into BusTimeModel. When the API call is finished, the
    /// function produces the BusTimeModel.
    /// (https://www.translink.ca/about-us/doing-business-with-translink/app-developer-resources/rtti)
    ///
    /// - Parameters:
    ///     - routeNum: a String that represents to route number
    ///
    /// - Returns: Upon completion, the function returns the BusTimeModel of the given routeNum and selectedAnnotation's BusStopNumber
    func createBusStopTimes(routeNum: String, completion: @escaping ([BusTimeModel]?) -> Void){
        let API_Key: String = "pFrncMHWZCb8dy0xp0Ih"
        let url = URL(string: "https://api.translink.ca/rttiapi/v1/stops/" + selectedAnnotation.subtitle! + "/estimates?apikey=" + API_Key + "&routeNo=" + routeNum)!
        let group = DispatchGroup()
        group.enter()
        var request = URLRequest(url: url)
        request.setValue("application/JSON", forHTTPHeaderField: "accept")
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error ?? "Unknown error")
                completion(nil)
                return
            }
            do {
                let responseObject = try JSONDecoder().decode([BusTimeModel].self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject)
                }
                
            } catch let parseError {
                print(parseError)
                completion(nil)
            }
        }
        task.resume()
    }
}

//MARK: https://stackoverflow.com/questions/56760335/round-specific-corners-swiftui
// Used to make to BusPopUp have round corners

struct RoundedCorners: View {
    var color: Color = .blue
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                
                let w = geometry.size.width
                let h = geometry.size.height
                
                // Make sure we do not exceed the size of the rectangle
                let tr = min(min(self.tr, h/2), w/2)
                let tl = min(min(self.tl, h/2), w/2)
                let bl = min(min(self.bl, h/2), w/2)
                let br = min(min(self.br, h/2), w/2)
                
                path.move(to: CGPoint(x: w / 2.0, y: 0))
                path.addLine(to: CGPoint(x: w - tr, y: 0))
                path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
                path.addLine(to: CGPoint(x: w, y: h - br))
                path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
                path.addLine(to: CGPoint(x: bl, y: h))
                path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
                path.addLine(to: CGPoint(x: 0, y: tl))
                path.addArc(center: CGPoint(x: tl, y: tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
                path.closeSubpath()
            }
            .fill(self.color)
        }
    }
}

