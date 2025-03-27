//
//  MyCarView.swift
//  GestFront
//

import SwiftUI
import GoogleMaps

struct MyCarView: View {
    @StateObject private var viewModel = MyCarViewModel()
    @StateObject private var dailyActivitiesVM = DailyActivitiesViewModel()
    @StateObject private var trackingVM = DutyTrackingViewModel.shared
    @State private var path = GMSMutablePath()
    @State private var shouldPresentSheet = false
    
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
                        
                        MyCarInfoCard(title: "Last Location", value: trackingVM.lastLocationName ?? "Fetching...")
                        
                        HStack(spacing: 16) {
                            MyCarInfoCard(title: "Plate", value: car.licensePlate)
                            MyCarInfoCard(title: "Mileage", value: "\(car.mileage) km")
                        }
                        
                        HStack(spacing: 16) {
                            MyCarInfoCard(title: "VIN", value: car.vin)
                            MyCarInfoCard(title: "Inspection", value: viewModel.formattedDate(car.lastInspection))
                        }
                        
                        HStack(spacing: 16) {
                            MyCarInfoCard(title: "Insurance Valid", value: viewModel.formattedDate(car.insuranceExpiration))
                        }
                        
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
                        
                        GoogleMapsView(currentLocation: $trackingVM.currentLocation, path: $path)
                            .frame(height: 300)
                            .cornerRadius(12)
                        
                        if trackingVM.isDutyActive {
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
                        
                        if UserDefaults.standard.string(forKey: "user_role") == "Admin" {
                            NavigationLink(destination: AllCarsView()) {
                                Text("View All Cars")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.purple)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal)
                        }
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
                    CreateDailyActivityView(viewModel: CreateDailyActivityViewModel(
                        description: details.description,
                        kilometers: details.kilometers,
                        date: details.date
                    ))
                } else {
                    ProgressView("Loading details...")
                }
            }
        }
    }
}

struct MyCarInfoCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    MyCarView()
}
