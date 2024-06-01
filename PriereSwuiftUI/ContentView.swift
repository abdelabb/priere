//
//  ContentView.swift
//  PriereSwuiftUI
//
//  Created by abbas on 24/04/2024.
//

import SwiftUI
import CoreLocation
import UserNotifications
import AVFoundation

enum NotificationMode: String, CaseIterable {
    case silencieux
    case desactiver
    case normal
    
    var imageName: String {
        switch self {
        case .silencieux:
            return "speaker.slash.fill"
        case .desactiver:
            return "speaker.fill"
        case .normal:
            return "speaker.wave.3.fill"
        }
    }
    
    
    var soundName: String {
        switch self {
        case .silencieux:
            return ""
        case .desactiver:
            return ""
        case .normal:
            return "Adhan.m4r"
        }
    }
}
enum PrayerType: String {
    case fajr
    case dhuhr
    case asr
    case maghreb
    case isha
}
struct PrayerTimesResponse: Codable {
    let code: Int
    let status: String
    let data: PrayerData
}

struct PrayerData: Codable {
    let timings: PrayerTimings
}

struct PrayerTimings: Codable {
    let Fajr: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
}
class NotificationSettings: ObservableObject {
    @Published var selectedFajr: NotificationMode = .normal
    @Published var selectedDhor: NotificationMode = .normal
    @Published var selectedAsr: NotificationMode = .normal
    @Published var selectedMaghreb: NotificationMode = .normal
    @Published var selectedIsha: NotificationMode = .normal
}


    struct ContentView: View {
        @State  var prayerTimes: PrayerTimings!
        @State var lat = 48.299999
        @State var long = 4.08333
        @State var date = Date.now
        @State var cityName = ""
        @State var countryName = ""
        @State var timeUntilNextPrayer: TimeInterval?
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        @State var nextPriere = PrayerType.fajr
        //@State var scheduledNotificationIDs: [PrayerType: Set<String>] = [:]
        
        @State private var selectedTab = "One"
        @StateObject var notificationSettings = NotificationSettings()
        
        
        
            @AppStorage("selectedFajr")  var selectedFajr: NotificationMode = .normal
            @AppStorage("selectedDhor")  var selectedDhor: NotificationMode = .normal
            @AppStorage("selectedAsr")  var selectedAsr: NotificationMode = .normal
            @AppStorage("selectedMaghreb")  var selectedMaghreb: NotificationMode = .normal
            @AppStorage("selectedisha")  var selectedisha: NotificationMode = .normal
        
        @State private var isRefreshing = false
        
        
        var body: some View {
            
            VStack{
                
                Text("\(countryName) : \(cityName)").padding(.bottom,5)
                
                
                if let timeUntilNextPrayer = timeUntilNextPrayer {
                    
                    HStack(alignment: .center) {
                        Text(" \(nextPriere):").bold().padding(.bottom,10)
                        Text("\(formattedTime(timeUntilNextPrayer))").font(.system(size: 20)).bold().padding(.bottom,10)
                        
                    }
                    
                    .onReceive(timer) { input in
                        date = input
                        self.timeUntilNextPrayer = tempsRestantJusquaProchainePriere(prayerTimes: prayerTimes)
                    }
                    
                } else {
                    Text("Impossible de calculer le temps restant jusqu'à la prochaine prière")
                }
                
                VStack {
                    
                    NotificationSound()
                    
                    List{
                        if let prayerTimes = prayerTimes{
                            
                            PrayertimeRow(prayer: "Fajr", time: prayerTimes.Fajr, selectedMode: $selectedFajr)
                            PrayertimeRow(prayer: "Dhuhr", time: prayerTimes.Dhuhr, selectedMode: $selectedDhor)
                            PrayertimeRow(prayer: "Asr", time: prayerTimes.Asr, selectedMode: $selectedAsr)
                            PrayertimeRow(prayer: "Maghrib",time: prayerTimes.Maghrib, selectedMode:  $selectedMaghreb)
                            PrayertimeRow(prayer: "Isha",time: prayerTimes.Isha, selectedMode: $selectedisha)
                            
                        }else{
                            
                            Text("Donnees manquantess")
                        }
                    }
                    
                    .refreshable {
                        refreshData()
                    }
                    
                    
                    
                }
                
                
                .onAppear {
                    print("La méthode onAppear est appelée")
                    
                    executerOnappear()
                }
            
            }
            
            
        }

        
        private func refreshData() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                fetchPrayerTimes(latitude: self.lat, longitude: self.long, date: date.formatted())
                isRefreshing = false
            }
        }
        
        func nextPrayerString(prayer: PrayerTimings) -> PrayerType? {
            let currenteDate = Date.now
            let dateFormmater = DateFormatter()
            dateFormmater.dateFormat = "HH:mm"
            let currentTimeString = dateFormmater.string(from: currenteDate)
            
            var nextPrayer: PrayerType? = nil
            var nexPrayerTime: String? = nil
            
            let prayers: [PrayerType: String] = [
                PrayerType.fajr : prayerTimes.Fajr,
                PrayerType.dhuhr : prayerTimes.Dhuhr,
                PrayerType.asr : prayerTimes.Asr,
                PrayerType.maghreb : prayerTimes.Maghrib,
                PrayerType.isha : prayerTimes.Isha
            ]
            
            for (key, prayerTime) in prayers {
                
                // Si l'heure de la prière est après l'heure actuelle
                if  prayerTime > currentTimeString {
                    
                    // Si c'est la première prière future que vous trouvez, initialisez nextPrayer avec celle-ci
                    if nextPrayer == nil {
                        
                        nextPrayer = key
                        nexPrayerTime = prayerTime
                    } else {
                        // Si une prière future a déjà été trouvée, comparez celle-ci avec la prochaine pour voir laquelle est plus proche dans le temps
                        if let nextPrayerTime = nexPrayerTime, prayerTime < nextPrayerTime {
                            nextPrayer = key
                            nexPrayerTime = prayerTime
                            
                            
                        }
                    }
                }
            }
            
            
            if let nextPrayer = nextPrayer {
                
                return nextPrayer
            } else {
                // Si aucune prière future n'est trouvée pour aujourd'hui
                return nil
            }
        }
        func executerOnappear() {
            
            DispatchQueue.main.async {
                reverseGeocode(latitude: lat, longitude: long)
                
                fetchPrayerTimes(latitude: lat, longitude: long, date: date.formatted())
            }
        }
        
        struct NotificationSound: View {
            var body: some View {
                VStack {
                    
                    let _: Void =     UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success {
                            print("All set!")
                        } else if let error {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
        
        func scheduleNotification(prayerType: PrayerType) {
            
            let notificationMode = getNotificationMode(for: prayerType)
            let center = UNUserNotificationCenter.current()
            let sonAdhan = UNNotificationSoundName(notificationMode.soundName) // Utilisez le mode de notification   en paramètre
            let content = UNMutableNotificationContent()
            
            content.title = "\(nextPriere)"
            content.body = "\(nextPriere)"
            //content.categoryIdentifier = "alarm"
            //content.userInfo = ["customData": "fizzbuzz"]
            print(" dans la function SCHEDUL scheduleNotification called for prayer type: \(prayerType)")
            
            switch notificationMode {
            case .normal:
                content.sound = UNNotificationSound(named: sonAdhan)
                
            case .desactiver:
                
                break
                
            case .silencieux:
                content.sound = UNNotificationSound.default
            }
            
            let prayerTime = getPrayerTime(for: prayerType)
            // 04:32 --> ["04", "32"]
            let splitPrayerTimeString = prayerTime.split(separator: ":")
            var dateComponents = DateComponents()
            dateComponents.hour = Int(splitPrayerTimeString[0])! // 04
            dateComponents.minute = Int(splitPrayerTimeString[1])! // 32
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            center.getPendingNotificationRequests { requests in
                let identifiers = requests.map { $0.identifier }
                if identifiers.contains(request.identifier) {
                    return
                }
            }
            
            center.add(request)
            
            
        }
        
        
        
        func formattedTime(_ timeInterval: TimeInterval) -> String {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute , .second]
            formatter.unitsStyle = .positional
            //print(timeInterval)
            
            return formatter.string(from: timeInterval)!
        }
        
        struct PrayertimeRow: View {
            var prayer: String
            var time: String
            @Binding var selectedMode: NotificationMode
            
            var body: some View {
                ZStack(alignment: .center) {
                    HStack {
                        Text(prayer)
                        Spacer()
                        Menu {
                            ForEach(NotificationMode.allCases, id: \.self) { mode in
                                Button(action: {
                                    selectedMode = mode
                                }) {
                                    Label(mode.rawValue, systemImage: mode.imageName)
                                }
                            }
                        } label: {
                            Image(systemName: selectedMode.imageName)
                        }
                    }
                    Text(time).font(.system(size: 25).bold()).padding()
                }
            }
        }
        
        
        func reverseGeocode(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
            let geocoder = CLGeocoder()
            let location = CLLocation(latitude: latitude, longitude: longitude)
            
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let placemark = placemarks?.first {
                    let cityName = placemark.locality ?? "" // Nom de la ville
                    let countryName = placemark.country ?? "" // Nom du pays
                    DispatchQueue.main.async {
                        self.cityName = cityName
                        self.countryName = countryName
                        
                    }
                }
            }
        }
        
        
        func tempsRestantJusquaProchainePriere(prayerTimes: PrayerTimings) -> TimeInterval? {
            let currentDate = Date()
            let calendar = Calendar.current
            
            _ = calendar.component(.hour, from: currentDate)
            _ = calendar.component(.minute, from: currentDate)
            
            var dateComponents = DateComponents()
            dateComponents.year = calendar.component(.year, from: currentDate)
            dateComponents.month = calendar.component(.month, from: currentDate)
            dateComponents.day = calendar.component(.day, from: currentDate)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            
            guard let fajrDate = dateFormatter.date(from: prayerTimes.Fajr),
                  let dhuhrDate = dateFormatter.date(from: prayerTimes.Dhuhr),
                  let asrDate = dateFormatter.date(from: prayerTimes.Asr),
                  let maghrebDate = dateFormatter.date(from: prayerTimes.Maghrib),
                  let ishaDate = dateFormatter.date(from: prayerTimes.Isha)
            else {
                print("Erreur: Impossible de convertir les heures de prière en format de date.")
                return nil
            }
            
            let fajrComponents = calendar.dateComponents([.hour, .minute], from: fajrDate)
            let dhuhrComponents = calendar.dateComponents([.hour, .minute], from: dhuhrDate)
            let asrComponents = calendar.dateComponents([.hour, .minute], from: asrDate)
            let maghrebComponents = calendar.dateComponents([.hour, .minute], from: maghrebDate)
            let ishaComponents = calendar.dateComponents([.hour, .minute], from: ishaDate)
            
            dateComponents.hour = fajrComponents.hour
            dateComponents.minute = fajrComponents.minute
            
            guard let fajr = calendar.date(from: dateComponents),
                  let dhuhr = calendar.date(bySettingHour: dhuhrComponents.hour!, minute: dhuhrComponents.minute!, second: 0, of: currentDate),
                  let asr = calendar.date(bySettingHour: asrComponents.hour!, minute: asrComponents.minute!, second: 0, of: currentDate),
                  let maghreb = calendar.date(bySettingHour: maghrebComponents.hour!, minute: maghrebComponents.minute!, second: 0, of: currentDate),
                  let isha = calendar.date(bySettingHour: ishaComponents.hour!, minute: ishaComponents.minute!, second: 0, of: currentDate)
            else {
                print("Erreur: Impossible de créer les dates des heures de prière.")
                return nil
            }
            
            let prayerTiesArray = [fajr, dhuhr, asr, maghreb, isha]
            
            
            let futurePrayers = prayerTiesArray.filter { $0 > currentDate }
            
            if let nextPrayerTime = futurePrayers.first {
                let timeRemaining = nextPrayerTime.timeIntervalSince(currentDate)
                
                
                // print("Temps restant jusqu'à la prochaine prière : \(timeRemaining) secondes")
                return timeRemaining
            } else {
                print("Aucune prochaine prière future.")
                return nil
            }
        }
        
        
        func getNotificationMode(for prayer: PrayerType) -> NotificationMode {
            switch prayer {
            case .fajr:
                return selectedFajr
            case .dhuhr:
                return selectedDhor
            case .asr:
                return selectedAsr
            case .maghreb:
                return selectedMaghreb
            case .isha:
                return selectedisha
            }
        }
        
        func getPrayerTime(for prayer: PrayerType) -> String {
            switch prayer {
            case .fajr:
                return prayerTimes.Fajr
            case .dhuhr:
                return prayerTimes.Dhuhr
            case .asr:
                return prayerTimes.Asr
            case .maghreb:
                return prayerTimes.Maghrib
            case .isha:
                return prayerTimes.Isha
            }
        }
        
        
        func  fetchPrayerTimes(latitude: CLLocationDegrees, longitude: CLLocationDegrees, date: String) {
            
            // @AppStorage("selectedMode")  var selectedMode: NotificationMode?
            let urlString = "https://api.aladhan.com/v1/timingsByCity?city=\(latitude)&country=\(longitude)&date=\(date)"
            
            guard let url = URL(string: urlString) else {
                print("Erreur: URL non valide")
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    
                    print("Erreur de requête : \(error.localizedDescription)")
                    
                    return
                }
                
                guard let data = data else {
                    print("Aucune donnée reçue pour les horaires de prière.")
                    
                    return
                }
                
                do {
                    let prayerTimesResponse = try JSONDecoder().decode(PrayerTimesResponse.self, from: data)
                    let prayerTimes = prayerTimesResponse.data.timings
                    DispatchQueue.main.async {
                        
                        
                        self.lat = lat
                        self.long = long
                        self.prayerTimes = prayerTimes
                        self.timeUntilNextPrayer = tempsRestantJusquaProchainePriere(prayerTimes: prayerTimes)
                        
                        
                        if let nextPrayer = nextPrayerString(prayer: prayerTimes) {
                            
                            self.nextPriere = nextPrayer
                            let notificationMode = getNotificationMode(for: nextPrayer)
                            
                            scheduleNotification(prayerType: nextPrayer)
                            //                        print("dans la function FETCH scheduleNotification called for prayer type: \(nextPrayer)")
                            
                        } else {
                            //print(" priere \(nextPrayer)")
                            print("Aucune prière future trouvée.")
                        }
                        
                    }
                } catch {
                    print("Erreur de décodage JSON : \(error.localizedDescription)")
                }
            }.resume()
            
            
        }

}

    
    class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
        private var locationManager = CLLocationManager()
        
        @Published var location: CLLocation?
        @Published var isLoading = false
        
        override init() {
            super.init()
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else { return }
            self.location = location
            
            
            isLoading = false
        }
    }

#Preview {
    ContentView()
}

