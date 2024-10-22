//
//  DonateView.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 12/23/23.
//

import SwiftUI
import FirebaseFirestore

struct Item: Identifiable {
    let id = UUID()
    let title: String
    let image: String
    let url: String
}


class DonateViewModel: ObservableObject {
    @Published var bags = 0
    @Published var items = 0
    @Published var meals = 0
    
    @Published var bagsDisplayValue = 0
    @Published var itemsDisplayValue = 0
    @Published var mealsDisplayValue = 0
    @Published var isViewed = false
    @Published var showUpdateView = false
    
    func getLiveCount() async throws -> [Int] {
        let doc = try await Firestore.firestore().collection("data").document("live_count").getDocument()
        
        return [doc.get("bags") as! Int, doc.get("items") as! Int, doc.get("meals") as! Int]
    }
    
    
    @MainActor
    func loadData() async {
        do {
            let data = try await getLiveCount()
            bags = data[0]
            items = data[1]
            meals = data[2]
            
        } catch {
            //Failed to load, just set at 0.
        }
    }
    
    
    func startTimer() {
        
        Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [self] timer in
            if abs(bagsDisplayValue - bags) < 10 {
                bagsDisplayValue = bags
                timer.invalidate()
            }
            
            if bagsDisplayValue < bags {
                bagsDisplayValue += 10
            } else if bagsDisplayValue > bags {
                bagsDisplayValue -= 10
            } else {
                timer.invalidate()
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [self] timer in
            if abs(mealsDisplayValue - meals) < 150 {
                mealsDisplayValue = meals
                timer.invalidate()
            }
            
            if mealsDisplayValue < meals {
                mealsDisplayValue += 150
            } else if mealsDisplayValue > meals {
                mealsDisplayValue -= 150
            } else {
                timer.invalidate()
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [self] timer in
            if abs(itemsDisplayValue - items) < 75 {
                itemsDisplayValue = items
                timer.invalidate()
            }
            
            if itemsDisplayValue < items {
                itemsDisplayValue += 200
            } else if itemsDisplayValue > items {
                itemsDisplayValue -= 200
            } else {
                timer.invalidate()
            }
        }
        
        
    }
}


struct DonateView: View {
    
    @StateObject var viewmodel = DonateViewModel()
    @Environment(\.openURL) var openURL
    @Binding var showSignInView: Bool
    
    @State private var show = false
    
    var body: some View {
        NavigationStack {
            ZStack (alignment: .top) {
                ScrollView {
                        if show {
                            Text("23-24 School Year")
                                .foregroundStyle(.secondary)
                                .bold()
                                .padding(.top, 20)
                                .transition(.opacity)
                        }
                        if show {
                            HStack {
                                LiveDataView(num: $viewmodel.bagsDisplayValue, text: "bags delivered")
                                LiveDataView(num: $viewmodel.mealsDisplayValue, text: "meals provided")
                                LiveDataView(num: $viewmodel.itemsDisplayValue, text: "items of food")
                            }
                            .padding(.horizontal, 5)
                            .transition(.opacity.animation(.easeInOut.delay(0.8)))
                            
                            if let result = UserManager.shared.currentDBUser?.isAdmin {
                                if result {
                                    Button {
                                        viewmodel.showUpdateView = true
                                    } label: {
                                        Text("Update")
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                            }
                        }
                        
                        if show {
                            HStack {
                                Text("Our Story")
                                    .bold()
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                            .transition(.opacity)
                            
                            VStack (alignment: .leading, spacing: 0){
                                Text("By partnering with 10 Blacksburg schools, Micah’s Backpack provides direct food assistance for students who are experiencing food insecurity. Every Friday during the school year, the identified students receive a backpack filled with two breakfasts, two lunches, two dinners, snacks, juice and milk boxes.")
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(viewmodel.isViewed ? 15 : 3)
                                Button(viewmodel.isViewed ? "Read Less" : "Read More" ) {
                                    viewmodel.isViewed.toggle()
                                }
                                .fontWeight(.semibold)
                                .font(.caption)
                                .foregroundStyle(.mbpBlue2)
                            }
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                            .transition(.opacity.animation(.easeInOut.delay(1.5)))
                            
                            HStack {
                                Text("Did you know?")
                                    .bold()
                                    .font(.title2)
                                Spacer()
                            }
                            .transition(.opacity.animation(.easeInOut.delay(1.8)))
                            .padding(.horizontal)
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                        }
                    
                    if show {
                        VStack{
                            Text("You can provide 6 Meals and Snacks for one child for . . .")
                            DonateDetailView(text: "a Weekend", donation: 8)
                            DonateDetailView(text: "a Summer of Weekends", donation: 64)
                            DonateDetailView(text: "a Semester of Weekends", donation: 160)
                            DonateDetailView(text: "a School Year of Weekends", donation: 320)
                        }
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .transition(.opacity.animation(.easeInOut.delay(2)))
                    }
                        if show {
                            Button {
                                openURL(URL(string: "https://secure.myvanco.com/L-Z4KW/campaign/C-129WZ")!)
                            } label: {
                                PrimaryButton(title: .constant("Donate"), color: .constant(.green))
                            }
                            .padding(.top)
                            .padding(.top)
                            .padding(.horizontal)
                            .padding(.bottom, 100)
                            .transition(.opacity.animation(.easeInOut.delay(2)))
                            
                        }
    
                    }
                    .scrollIndicators(.hidden)
                    .background(Color.primaryBg)

            }
            .sheet(isPresented: $viewmodel.showUpdateView, onDismiss: {viewmodel.startTimer()}, content: {
                UpdateDonateView(bags: $viewmodel.bags, items: $viewmodel.items, meals: $viewmodel.meals, showUpdateView: $viewmodel.showUpdateView)
            })
            .transition(.opacity)
            
            
        }
        .onAppear {
            Task {
                await viewmodel.loadData()
            }
            withAnimation (Animation.easeInOut(duration: 1.25)) {
                self.show = true
            }
            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                viewmodel.startTimer()
            }
            
        }
    }
}

struct ItemView: View {
    
    let item: Item
    
    var body: some View {
        let width = 330 as CGFloat
        let height = 300 as CGFloat
        ZStack {
            GeometryReader { reader in
                VStack(spacing: 5){
                    Image(item.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: width)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.top, 10)
                    Spacer()
                    Text(item.title)
                        .font(.largeTitle)
                        .fontWeight(.medium)
                        .padding(.bottom, 10)
                }
                .frame(width: reader.size.width, height: reader.size.height)
            }
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 5)
            
            Link(destination: URL(string: item.url)!, label: {
                Text("")
                    .frame(width: width, height: height)
                    .padding(.horizontal)
            })
        }
    }
}
#Preview {
    DonateView(showSignInView: .constant(false))
}

struct LiveDataView: View {
    @Binding var num: Int
    let text: String
    var body: some View {
        VStack (alignment: .center) {
            Text("\(num)")
                .font(.system(size: 30))
                .bold()
                .foregroundStyle(.mbpBlack)
            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .stroke(.gray, lineWidth: 2)
        )
    }
}




struct DonateDetailView: View {
    let text: String
    let donation: Int
    var body: some View {
        HStack (spacing: 2){
            Text("$\(donation)")
                .foregroundStyle(.green)
                .bold()
            Text("- \(text)")
            Spacer()
        }
        .font(.system(size: 20))
        .padding(.leading)
        .padding(.vertical, 2)
    }
}
