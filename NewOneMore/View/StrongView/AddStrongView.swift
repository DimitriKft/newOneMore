//
//  AddWodView.swift
//  NewOneMore
//
//  Created by dimitri on 18/09/2024.
//

import SwiftUI
import SwiftData

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var selectedStrongs: [String]
    
    @State private var selectedItem: StrongMove? = nil
    @State private var availableItems = stringMoovs // Liste dynamique d'items disponibles
    @State private var selectedCategory: Categories? = nil // Catégorie sélectionnée
    @State private var searchText: String = "" // Texte de la barre de recherche
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            
            // Le contenu principal
            VStack(spacing: 20) {
                HStack{
                    BtnActionView(iconSF: "arrow.backward", color: .white) {
                        dismiss()
                    }
                    .padding(.top, 25)
                    .padding(.leading, 30)
                    Spacer()
//                    Text("Sélectionnez un mouvement")
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                        .padding(.leading, 0)
//                        .padding(.top, 25)
                }
                HStack(alignment: .top, spacing: 65){
                    ButtonCategorieView(selectedCategory: $selectedCategory, category: nil)
                    ButtonCategorieView(selectedCategory: $selectedCategory, category: .halterophilie)
                    ButtonCategorieView(selectedCategory: $selectedCategory, category: .musculation)
                }
                .padding(.horizontal)
                
                // Barre de recherche
                TextField("Rechercher un mouvement", text: $searchText)
                    .padding(10)
                    .frame(width: 340)
                    .background(Color(.black))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                // Liste des mouvements en grille
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredItems(), id: \.self) { item in
                            MoovChoiceView(
                                item: item,
                                isSelected: selectedItem == item,
                                onSelect: { selectedItem = item }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedItem == item ? colorForCategory(item.category) : Color.clear, lineWidth: 2) // Halo autour de l'élément sélectionné
                            )
                            .shadow(color: selectedItem == item ? colorForCategory(item.category).opacity(0.2) : Color.clear, radius: 2, x: 0, y: 0) // Ombre douce avec la couleur de la catégorie
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            
            // Bouton flottant en bas de l'écran
            if let selectedItem = selectedItem {
                VStack {
                    Spacer() // Pousse le bouton en bas
                    Button {
                        ajouterItem()
                    } label: {
                        ZStack{
                            Rectangle()
                                .frame(width: 300, height: 50)
                                .cornerRadius(12)
                                .foregroundColor(.white)
                            HStack(alignment: .firstTextBaseline, spacing: 20){
                                Text("Ajouter \(selectedItem.nom)")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity)) // Transition fluide
                    
                }
                .padding(.bottom, 20) // Espace sous le bouton
            }
        }
        .navigationBarItems(leading: Button("Annuler") {
            dismiss()
        })
    }
    
    // Fonction qui retourne la couleur associée à la catégorie
    func colorForCategory(_ category: Categories) -> Color {
        switch category {
        case .halterophilie:
            return Color.yellow
        case .musculation:
            return Color.red
        case .powerLifting:
            return Color.blue
        }
    }
    
    // Filtrage des items en fonction de la catégorie et du texte de recherche
    func filteredItems() -> [StrongMove] {
        availableItems.filter { item in
            (selectedCategory == nil || item.category == selectedCategory) &&
            !selectedStrongs.contains(item.nom) &&
            (searchText.isEmpty || item.nom.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    func ajouterItem() {
        guard let selectedItem = selectedItem else { return }
        
        let nouvelItem = Strong(
            nom: selectedItem.nom,
            subtitle: selectedItem.subtitle,
            image: selectedItem.imageName,
            descriptionName: "",
            scores: [],
            dates: [Date()],
            categories: [selectedItem.category]
        )
        
        modelContext.insert(nouvelItem)
        dismiss()
    }
}

#Preview {
    AddItemView(selectedStrongs: ["empty!"])
        .modelContainer(for: Strong.self)
}
