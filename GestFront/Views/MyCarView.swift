import SwiftUI
import GoogleMaps

struct MyCarView: View {
    @StateObject private var viewModel = MyCarViewModel()
    @StateObject private var dailyActivitiesVM = DailyActivitiesViewModel()
    @StateObject private var trackingVM = DutyTrackingViewModel.shared
    @State private var path = GMSMutablePath()
    @State private var shouldPresentSheet = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        return formatter
    }
    
    private var isInspectionOverdue: Bool {
        guard let car = viewModel.car,
              let inspectionDate = dateFormatter.date(from: car.lastInspection) else { return false }
        return Date().timeIntervalSince(inspectionDate) > (365 * 24 * 60 * 60)
    }
    
    private var isOilChangeOverdue: Bool {
        guard let car = viewModel.car,
              let oilChangeDate = dateFormatter.date(from: car.lastOilChange) else { return false }
        return Date().timeIntervalSince(oilChangeDate) > (180 * 24 * 60 * 60)
    }
    
    private var isTireChangeOverdue: Bool {
        guard let car = viewModel.car,
              let tireChangeDate = dateFormatter.date(from: car.lastTireChange) else { return false }
        return Date().timeIntervalSince(tireChangeDate) > (365 * 24 * 60 * 60)
    }
    
    private var isInsuranceExpired: Bool {
        guard let car = viewModel.car,
              let insuranceDate = dateFormatter.date(from: car.insuranceExpiration) else { return false }
        return Date() > insuranceDate
    }
    
    private var isAnyAlertActive: Bool {
        isInspectionOverdue || isOilChangeOverdue || isTireChangeOverdue || isInsuranceExpired
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Image(systemName: "car.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                    
                    if let car = viewModel.car {
                        Text("\(car.carMake.make) \(car.carModel.model)")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 8) {
                            if isInspectionOverdue {
                                AlertBanner(message: "Inspection overdue! Please update your inspection record.")
                            }
                            if isOilChangeOverdue {
                                AlertBanner(message: "Oil change overdue! Please update your oil change record.")
                            }
                            if isTireChangeOverdue {
                                AlertBanner(message: "Tire change overdue! Please update your tire change record.")
                            }
                            if isInsuranceExpired {
                                AlertBanner(message: "Insurance expired! Please update your insurance details.")
                            }
                        }
                        .padding(.horizontal)
                        
                        MyCarInfoCard(title: "Last Location", value: trackingVM.lastLocationName ?? "Fetching...")
                        
                        HStack(spacing: 16) {
                            MyCarInfoCard(title: "Plate", value: car.licensePlate)
                            MyCarInfoCard(title: "Mileage", value: "\(car.mileage) km")
                        }
                        
                        HStack(spacing: 16) {
                            MyCarInfoCard(title: "Inspection", value: viewModel.formattedDate(car.lastInspection))
                            MyCarInfoCard(title: "Oil Change", value: viewModel.formattedDate(car.lastOilChange))
                        }
                        
                        HStack(spacing: 16) {
                            MyCarInfoCard(title: "Tire Change", value: viewModel.formattedDate(car.lastTireChange))
                            MyCarInfoCard(title: "Insurance Valid", value: viewModel.formattedDate(car.insuranceExpiration))
                        }
                        
                        // Butoane de Maintenance
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Maintenance Actions")
                                .font(.headline)
                            
                            Button(action: {
                                guard let car = viewModel.car else { return }
                                CarMaintenanceService.shared.markMaintenance(carId: Int(car.id)) { result in
                                    DispatchQueue.main.async {
                                        switch result {
                                        case .success():
                                            print("Inspection marked as done successfully.")
                                            viewModel.fetchCar()
                                        case .failure(let error):
                                            print("Error marking inspection: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            }) {
                                Text("Mark Inspection Done")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                guard let car = viewModel.car else { return }
                                CarMaintenanceService.shared.markTireChange(carId: Int(car.id)) { result in
                                    DispatchQueue.main.async {
                                        switch result {
                                        case .success():
                                            print("Tire change renewed successfully.")
                                            viewModel.fetchCar()
                                        case .failure(let error):
                                            print("Error renewing tires: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            }) {
                                Text("Renew Tires")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                guard let car = viewModel.car else { return }
                                CarMaintenanceService.shared.markInsurance(carId: Int(car.id)) { result in
                                    DispatchQueue.main.async {
                                        switch result {
                                        case .success():
                                            print("Insurance reviewed successfully.")
                                            viewModel.fetchCar()
                                        case .failure(let error):
                                            print("Error reviewing insurance: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            }) {
                                Text("Review Insurance")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Consum de combustibil (grafic)
                        if dailyActivitiesVM.isLoading {
                            ProgressView("Loading fuel consumption data...")
                                .padding()
                        } else if let error = dailyActivitiesVM.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                        } else {
                            FuelConsumptionChartView(data: dailyActivitiesVM.fuelConsumptionData)
                                .frame(height: 250)
                                .padding()
                        }
                        
                        // Harta Google
                        GoogleMapsView(currentLocation: $trackingVM.currentLocation, path: $path)
                            .frame(height: 300)
                            .cornerRadius(12)
                        
                        // Duty Buttons and Speedometer
                        if trackingVM.isDutyActive {
                            SpeedometerView(trackingVM: trackingVM)
                            
                            Button("Stop Duty") {
                                trackingVM.stopDuty()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                            
                            Text("Avg Speed: \(String(format: "%.1f", trackingVM.averageSpeed)) km/h")
                                .padding()
                        } else {
                            Button("Start Duty") {
                                trackingVM.startDuty()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            .disabled(isAnyAlertActive)
                        }
                        
                        NavigationLink(destination: DailyActivitiesView()) {
                            Text("View Daily Activities")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    } else {
                        if viewModel.isLoading {
                            ProgressView("Loading Car...")
                        } else if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                        } else {
                            Text("No car data available.")
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("My Car")
            .onAppear {
                viewModel.fetchCar()
                dailyActivitiesVM.fetchActivities()
                trackingVM.fetchLastLocation()
            }
            .onChange(of: trackingVM.didEndDuty) { newValue in
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        shouldPresentSheet = true
                    }
                }
            }
            .sheet(isPresented: $shouldPresentSheet, onDismiss: {
                trackingVM.didEndDuty = false
            }) {
                if let details = trackingVM.calculatedDutyDetails {
                    CreateDailyActivityView(
                        viewModel: CreateDailyActivityViewModel(
                            description: details.description,
                            kilometers: details.kilometers,
                            date: details.date,
                            fuelConsumption: 0.0
                        )
                    )
                } else {
                    ProgressView("Loading details...")
                }
            }
        }
    }
}
