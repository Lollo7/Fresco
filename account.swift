import SwiftUI

struct AccountView: View {
    @State private var username: String = "Akshat Arya"
    @State private var email: String = "akshatar@umich.edu"

    var body: some View {
        NavigationView {
            VStack {
                // Profile Section
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                    VStack(alignment: .leading) {
                        Text(username)
                            .font(.title)
                            .fontWeight(.bold)
                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding()

                // Account Options
                Form {
                    Section(header: Text("Account Settings")) {
                        NavigationLink(destination: Text("Edit Profile Page")) {
                            HStack {
                                Image(systemName: "person.crop.circle")
                                    .foregroundColor(.blue)
                                Text("Edit Profile")
                            }
                        }
                        NavigationLink(destination: Text("Notifications Settings Page")) {
                            HStack {
                                Image(systemName: "bell.circle")
                                    .foregroundColor(.orange)
                                Text("Notifications")
                            }
                        }
                        NavigationLink(destination: Text("Privacy Settings Page")) {
                            HStack {
                                Image(systemName: "lock.circle")
                                    .foregroundColor(.green)
                                Text("Privacy Settings")
                            }
                        }
                        NavigationLink(destination: Text("Account Security Page")) {
                            HStack {
                                Image(systemName: "shield.circle")
                                    .foregroundColor(.red)
                                Text("Account Security")
                            }
                        }
                    }
                    
                    // Other Options
                    Section(header: Text("More Options")) {
                        NavigationLink(destination: Text("Help Page")) {
                            HStack {
                                Image(systemName: "questionmark.circle")
                                    .foregroundColor(.purple)
                                Text("Help")
                            }
                        }
                        NavigationLink(destination: Text("About Page")) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.gray)
                                Text("About")
                            }
                        }
                    }
                }
                
                Spacer()

                // Logout Button
                Button(action: {
                    // Add logout functionality here
                    print("User logged out")
                }) {
                    Text("Logout")
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Account")
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
