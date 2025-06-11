import SwiftUI
import GoogleMaps

struct MyTasksView: View {
    @StateObject private var viewModel = MyTasksViewModel()
    @State private var showVirtualCockpit = false
    @StateObject private var trackingVM = DutyTrackingViewModel.shared
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Image(systemName: "list.bullet.clipboard.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                    
                    if viewModel.isLoading {
                        ProgressView("Loading tasks...")
                            .padding()
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else if viewModel.tasks.isEmpty {
                        Text("No tasks assigned.")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(viewModel.tasks) { task in
                            TaskCardView(task: task, viewModel: viewModel, showVirtualCockpit: $showVirtualCockpit)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("My Tasks")
            .onAppear {
                viewModel.fetchTasks()
            }
            .fullScreenCover(isPresented: $showVirtualCockpit) {
                VirtualCockpitView(trackingVM: trackingVM, path: .constant(GMSMutablePath()))
            }
        }
    }
}

struct TaskCardView: View {
    let task: Task
    let viewModel: MyTasksViewModel
    @Binding var showVirtualCockpit: Bool
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(task.startingPoint) to \(task.destination)")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let description = task.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                MyTaskInfoCard(title: "Status", value: task.status.capitalized)
                MyTaskInfoCard(title: "Priority", value: task.priority.capitalized)
            }
            
            if let dueDate = task.dueDate, let formattedDate = dateFormatter.date(from: dueDate) {
                MyTaskInfoCard(title: "Due Date", value: dateFormatter.string(from: formattedDate))
            }
            
            HStack(spacing: 8) {
                if task.status != "STARTED" && task.status != "COMPLETED" {
                    Button(action: {
                        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
                            viewModel.errorMessage = "User ID not found"
                            return
                        }
                        viewModel.startTask(taskId: task.id, userId: userId) { result in
                            switch result {
                            case .success:
                                DutyTrackingViewModel.shared.startDuty(task: task)
                                showVirtualCockpit = true
                            case .failure(let error):
                                viewModel.errorMessage = error.localizedDescription
                            }
                        }
                    }) {
                        Text("Start Task")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                
                if task.status == "STARTED" {
                    Button(action: {
                        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
                            viewModel.errorMessage = "User ID not found"
                            return
                        }
                        viewModel.stopTask(taskId: task.id, userId: userId) { result in
                            switch result {
                            case .success:
                                viewModel.fetchTasks()
                            case .failure(let error):
                                viewModel.errorMessage = error.localizedDescription
                            }
                        }
                    }) {
                        Text("Stop Task")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                
                if task.status != "COMPLETED" {
                    Button(action: {
                        guard let userId = UserDefaults.standard.value(forKey: "user_id") as? Int else {
                            viewModel.errorMessage = "User ID not found"
                            return
                        }
                        viewModel.completeTask(taskId: task.id, userId: userId) { result in
                            switch result {
                            case .success:
                                viewModel.fetchTasks()
                            case .failure(let error):
                                viewModel.errorMessage = error.localizedDescription
                            }
                        }
                    }) {
                        Text("Complete Task")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// Define MyTaskInfoCard to display task attributes
struct MyTaskInfoCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}
