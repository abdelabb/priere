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

 

struct ViewCoran: View {
    

    @State private var selectedTab = "One"
    @State var progress = NotificationSettings()

   
    var body: some View {
        CustomTabView(selectedTab: $selectedTab)
        InnerView(progress: progress)


               
    }
 
    struct InnerView: View {
        @ObservedObject var progress: NotificationSettings

        var body: some View {
           // progress.$selectedAsr
            Text("")

            
        }
    }

    
    protocol TabViewProvider{
        associatedtype Content: View
        func provideTabView(selectedTab: Binding<String>) -> Content
    }

    struct CustomTabView: View , TabViewProvider {
        @Binding var selectedTab: String
        var prayerTime: PrayerTimings!
        var contentView = ContentView()
//        @Binding var notificationSetting = NotificationSettings()




        var body: some View{
            provideTabView(selectedTab: $selectedTab)
        }
        
        
        func provideTabView(selectedTab: Binding<String>) -> some View {
            
            
                TabView(selection: selectedTab) {
                    
                 
                    NavigationView{
                        ContentView()

                        NavigationLink(destination: Text("Prayer") ) {

                        }
                    }

                    .tabItem {
                        Label("Prayer", systemImage: "alarm")
                    }
                    
                    NavigationView{
                        BoussolView()
                        NavigationLink(destination: Text("Boussole")) {
                                
                              
                            }
                    }

                        .tabItem {
                            Label("Boussol", systemImage: "compass.drawing")
                        }
                    
                    
                  
                    NavigationView{
                        PrayerView()

                        NavigationLink(destination: Text("book")) {
                        }
                    }
                    
                   
                    .tabItem {
                        Label("Coran", systemImage: "book")
                    }
                    .safeAreaPadding()

                }
            
            
            
        }
        
        
    }
}








//extension ContentView: TabViewProvider {
//    func provideTabView() -> some View {
//        CustomTabView().provideTabView()
//    }
//}



#Preview {
    ViewCoran()
}
