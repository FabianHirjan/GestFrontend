//
//  MyCarView.swift
//  GestFront
//
//  Created by Fabian Andrei Hirjan on 21.03.2025.
//

import SwiftUI
import GoogleMaps

struct MyCarView: View {
    @StateObject private var viewModel = MyCarViewModel()
    @StateObject private var dailyActivitiesVM = DailyActivitiesViewModel()
    @StateObject private var trackingVM = DutyTrackingViewModel.shared
    @State private var path = GMSMutablePath()

    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var shouldPresentSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Icon
                Image(systemName: "car.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                    .padding(.top, 20)

                if let car = viewModel.car {
                    // Titlu cu make & model
                    Text("\(car.carMake.make ?? "") \(car.carModel.model ?? "")")
                        .font(.title)
                        .fontWeight(.bold)

                    // Info card 1
                    HStack(spacing: 16) {
                        MyCarInfoCard(title: "Plate", value: car.licensePlate)
                        MyCarInfoCard(title: "Mileage", value: "\(car.mileage) km")
                    }

                    // Info card 2
                    HStack(spacing: 16) {
                        MyCarInfoCard(title: "VIN", value: car.vin)
                        MyCarInfoCard(title: "Inspection", value: viewModel.formattedDate(car.lastInspection))
                    }

                    // Info card 3
                    HStack(spacing: 16) {
                        MyCarInfoCard(title: "Insurance Valid", value: viewModel.formattedDate(car.insuranceExpiration))
                    }

                    // Grafic consum combustibil
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

                    // Hartă Google Maps
                    GoogleMapsView(currentLocation: $trackingVM.currentLocation, path: $path)
                        .frame(height: 300)
                        .cornerRadius(12)

                    // Butoane Start / Stop duty + viteză medie
                    if trackingVM.isDutyActive {
                        Button("Stop Duty") {
                            print("[DEBUG] Stop Duty button pressed!")
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

                    // Buton de navigare la Daily Activities
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
                    // Dacă nu avem date despre mașină
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
        }
        // Observă schimbarea didEndDuty
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
                    fuelConsumption: details.fuelConsumption
                ))
            } else {
                ProgressView("Loading details...")
            }
        }



    }
}

// Card simplu pentru MyCar
struct MyCarInfoCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
        }
        .frame(minWidth: 100)
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(8)
    }
}
