//
//  ViewCoran.swift
//  PriereSwuiftUI
//
//  Created by abbas on 11/05/2024.
//

import SwiftUI
import CoreLocation
import UserNotifications
import AVFoundation



struct MainTabView: View {
    
    
    @State private var selectedTab = "One"
    @State var progress = NotificationSettings()
    
    
    
    
    var body: some View {
        
        TabView(selection: $selectedTab){
            TimePrayerData()
                .tabItem {
                    Label("Prayer", systemImage: "alarm")
                }
            BoussolData()
                .tabItem {
                    Label("Boussol", systemImage: "compass.drawing")
                }
            CoranData()
                .tabItem {
                    Label("Coran", systemImage: "book")
                    
                }
            
            
        }
    }
    
    struct TimePrayerData: View{
        var body: some View{
            NavigationView{
                
                ContentView()
                
                NavigationLink(destination: Text("Prayer") ) {
                    
                    
                }
                
            }
        }
        
        
    }
    struct BoussolData: View{
        var body: some View{
            NavigationView{
                BoussolView()
                NavigationLink(destination: Text("Boussole")) {
                    
                    
                }
                
            }
        }
    }
    struct CoranData:View{
        var body: some View{
            NavigationView{
                CoranView()
                
                NavigationLink(destination: Text("book")) {
                }
                
            }
            
        }
    }
}


#Preview {
    MainTabView()
}
