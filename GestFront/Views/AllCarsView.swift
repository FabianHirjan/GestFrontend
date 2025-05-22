import SwiftUI

struct AllCarsView: View {
    @StateObject private var viewModel = AllCarsViewModel()
    @State private var showingAssignSheet = false
    @State private var selectedCarId: Int64?
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading cars...")
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    List {
                        ForEach(viewModel.cars, id: \.id) { car in
                            HStack {
                                Text("🚗")
                                    .font(.title)
                                VStack(alignment: .leading) {
                                    Text("\(car.carMake.make) \(car.carModel.model)")
                                        .font(.headline)
                                    Text("Plate: \(car.licensePlate)")
                                        .font(.subheadline)
                                    Text("Driver: \(car.driver?.username ?? "Unassigned")")
                                        .font(.subheadline)
                                        .foregroundColor(car.driver == nil ? .gray : .black)
                                }
                                Spacer()
                                if car.driver == nil {
                                    Button("Assign") {
                                        selectedCarId = car.id
                                        showingAssignSheet = true
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("All Cars")
            .onAppear {
                viewModel.fetchCars()
            }
            .sheet(isPresented: $showingAssignSheet) {
                AssignDriverView(carId: selectedCarId ?? 0, viewModel: viewModel)
            }
        }
    }
}

struct AssignDriverView: View {
    let carId: Int64
    @ObservedObject var viewModel: AllCarsViewModel
    @State private var userId: String = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Assign Driver to Car")
                .font(.headline)
                .padding()
            
            TextField("Enter User ID", text: $userId)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .padding()
            
            Button("Assign") {
                if let id = Int64(userId) {
                    viewModel.assignCar(carId: carId, userId: id)
                    dismiss()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .padding()
            
            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
        .padding()
    }
}

#Preview {
    AllCarsView()
}
