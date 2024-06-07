//
//  BoussolView.swift
//  PriereSwuiftUI
//
//  Created by abbas on 11/05/2024.
//

import SwiftUI

struct BoussolView: View {
    @ObservedObject var locationManager = LocationManager()

    var body: some View {
        VStack {
            if let heading = locationManager.heading {
                let angle = Angle(degrees: locationManager.qiblaDirection - heading.magneticHeading)
                
                CompassNeedle(angle: angle)
                    //.frame(width: 200, height: 200)
                    .padding()
                
                
                Text("Direction de la Qibla")
                    .font(.headline)
                
                Text("Angle: \(Int(locationManager.qiblaDirection))°")
                    .font(.subheadline)
            } else {
                Text("Calibrating...")
            }
        }
        .onAppear {
            locationManager.calculateQiblaDirection()
        }
    }
}

struct CompassNeedle: View {
    let angle: Angle

    var body: some View {

        VStack {
            Image("icons8")
            //Spacer()
            .padding()
               
                
            
            ZStack {
                
                Circle()
                    .stroke(lineWidth: 10)
                    .frame(width: 200, height: 200)
                    .foregroundColor(.gray)
                    

                
                Text("Qibla: \(Int(angle.degrees))°")
                
                
                VStack {

                    Image(systemName: "triangle.fill")

                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.red)
                        .offset(y: -115)
                    // .rotationEffect(angle)
//                     Spacer()
                }
                .rotationEffect(angle)
                
            }
        }
        
    }
}

struct QiblaCompassView_Previews: PreviewProvider {
    static var previews: some View {
        BoussolView()
    }
}


#Preview {
    BoussolView()
}
