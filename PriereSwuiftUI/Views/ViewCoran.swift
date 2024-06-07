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
        //CustomTabView(selectedTab: $selectedTab)
        //InnerView(progress: progress)
        TabView(selection: $selectedTab){
            Contenter()
                .tabItem {
                    Label("Prayer", systemImage: "alarm")
                        .animation(.spring, value: selectedTab)
                }
            Boussol()
                .tabItem {
                    Label("Boussol", systemImage: "compass.drawing")
                        .animation(.snappy, value: selectedTab)
                }
            Coran()
                .tabItem {
                    Label("Coran", systemImage: "book")
                        .animation(.easeInOut, value: selectedTab)
                    
                }
            
            
        }
        .animation(.snappy, value: selectedTab)
    }
 
 //

    
//    protocol TabViewProvider{
//        associatedtype Content: View
//        func provideTabView(selectedTab: Binding<String>) -> Content
//    }
    
    struct Contenter: View{
        var body: some View{
            NavigationView{
                
                ContentView()

                NavigationLink(destination: Text("Prayer") ) {

                    
                }
                .onAppear {
                    withAnimation(.smooth(duration: 1)) {
                                      
                                   }
                               }
            }
        }
      
        
    }
    struct Boussol: View{
        var body: some View{
            NavigationView{
                BoussolView()
                NavigationLink(destination: Text("Boussole")) {
                        
                      
                    }
                .onAppear {
                    withAnimation(.smooth(duration: 1)) {
                                      
                                   }
                               }
            }
        }
    }
    struct Coran:View{
        var body: some View{
            NavigationView{
                PrayerView()

                NavigationLink(destination: Text("book")) {
                }
                
            }
            .onAppear {
                withAnimation(.interactiveSpring(duration: 5)) {
                                  
                               }
                           }
        }
    }

//    struct CustomTabView: View , TabViewProvider {
//        @Binding var selectedTab: String
//        var prayerTime: PrayerTimings!
//        var contentView = ContentView()
////        @Binding var notificationSetting = NotificationSettings()
//
//
//
//
//        var body: some View{
//            provideTabView(selectedTab: $selectedTab)
//        }
//        
//        
//        func provideTabView(selectedTab: Binding<String>) -> some View {
//            
//            
//            TabView(selection: selectedTab) {
//                    
////                    NavigationView{
////                        
////                        ContentView()
////
////                        NavigationLink(destination: Text("Prayer") ) {
////
////                        }
////                    }
//
////                    .tabItem {
////                        Label("Prayer", systemImage: "alarm")
////
////                    }
//                    
////                    NavigationView{
////                        BoussolView()
////                        NavigationLink(destination: Text("Boussole")) {
////                                
////                              
////                            }
////                    }
//
////                        .tabItem {
////                            Label("Boussol", systemImage: "compass.drawing")
////
////                        }
//                    
//                    
//                  
////                    NavigationView{
////                        PrayerView()
////
////                        NavigationLink(destination: Text("book")) {
////                        }
////                    }
//                    
//                   
////                    .tabItem {
////                        Label("Coran", systemImage: "book")
////
////                    }
//
//
//
//                }                        
//            
//
//
//        }
//        
//        
//    }
}


//extension ContentView: TabViewProvider {
//    func provideTabView() -> some View {
//        CustomTabView().provideTabView()
//    }
//}



#Preview {
    ViewCoran()
}
