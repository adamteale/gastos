//
//  ExpenseDetailView.swift
//  Gastos
//
//  Created by Adam Teale on 25-11-22.
//

import Foundation
import SwiftUI

struct ExpenseDetailViewArgs {
    let viewModel: ExpenseDetailViewModel
}

struct ExpenseDetailView: View {
    
    @ObservedObject private var viewModel: ExpenseDetailViewModel
    
    @State private var selectedCategory: Int = 0
    @State private var selectedAccount: Int = 0
    
    @FocusState private var titleIsFocused: Bool
    @FocusState private var amountIsFocused: Bool
    @State private var showDeleteConfirmation = false

    init(
        args: ExpenseDetailViewArgs
    ) {
        self.viewModel = args.viewModel
    }
    
    var body: some View {
        
        ScrollView {
            
            VStack (spacing: 16) {
                HStack(alignment: .center) {
                    Spacer()
                    HStack {
                        Text("$")
                            .font(.system(size: 30))
                            .fontWeight(.heavy)
                            .frame(alignment:.trailing)
                        TextField(
                            "",
                            value: $viewModel.amount,
                            format: .number
                        )
#if os(iOS)
                        .fontWeight(.heavy)
                        .font(.system(size: 60))
                        .keyboardType(.decimalPad)
#endif
                        .onChange(of: viewModel.amount ?? 0, perform: { newValue in
                            viewModel.onUpdateAmount(newValue)
                        })
                        .onSubmit {
                            amountIsFocused = false
                            titleIsFocused = true
                            viewModel.onSave()
                        }
                        .focused($amountIsFocused)
                    }
                    Spacer()
                }
                
#if os(iOS)
                TextField(
                    "Desc",
                    text: $viewModel.title,
                    axis: .vertical
                )
                .font(.system(size: 40))
                .focused($titleIsFocused)
                .onSubmit {
                    titleIsFocused = false
                    viewModel.onSave()
                }
#else
                TextField(
                    "Desc",
                    text: $viewModel.title
                )
                .multilineTextAlignment(.leading)
                .font(.system(size: 40))
                .focused($titleIsFocused)
                .onSubmit {
                    titleIsFocused = false
                    viewModel.onSave()
                }
#endif
                DatePicker(
                    "fecha",
                    selection: $viewModel.date,
                    displayedComponents: [.date]
                )
                .labelsHidden()

                HStack(alignment: .center) {
                    Text("Account")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(systemName: "plus.circle")
                        .font(.system(size: 30.0, weight: .semibold))
                        .onTapGesture {
                            viewModel.onAddAccount()
                        }
                }
                TagCloudView(
                    tags: viewModel.availableAccounts,
                    currentSelection: {
                        if let account = viewModel.account {
                            return [account]
                        } else {
                            return nil
                        }
                    }(),
                    onUpdate: viewModel.onUpdateAccount,
                    onEditTag: viewModel.onEditAccount,
                    displayVertically: true
                )
                
                HStack {
                    Text("Category")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "plus.circle")
                        .font(.system(size: 30.0, weight: .semibold))
                        .onTapGesture {
                            viewModel.onAddCategory()
                        }
                }
                TagCloudView(
                    tags: viewModel.availableCategories,
                    currentSelection: {
                        if let category = viewModel.category {
                            return [category]
                        } else {
                            return nil
                        }
                    }(),
                    onUpdate: viewModel.onUpdateCategory,
                    onEditTag: viewModel.onEditCategory,
                    displayVertically: true
                )
                
                HStack{
                    Text("Tags")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "plus.circle")
                        .font(.system(size: 30.0, weight: .semibold))
                        .onTapGesture {
                            viewModel.onAddTag()
                        }
                }
                TagCloudView(
                    tags: viewModel.availableTags,
                    currentSelection: Array(viewModel.tags),
                    onUpdate: viewModel.onUpdateTag,
                    onEditTag: viewModel.onEditTag,
                    displayVertically: true
                )

            }
            .padding()
        }
        .navigationDestination(for: HomeCoordinator.Scene.self, destination: { scene in
            switch scene {
            case .expenseDetail:
                Group{}
            case .categoryDetail(let category):
                CategoryDetailView(
                    viewModel: CategoryDetailViewModel(
                        category: category,
                        categories: viewModel.availableCategories,
                        managedObjectContext: viewModel.managedObjectContext
                    )
                )

            case .tagDetail(let tag):
                TagDetailView(
                    viewModel: TagDetailViewModel(
                        tag: tag,
                        tags: viewModel.availableTags,
                        managedObjectContext: viewModel.managedObjectContext
                    )
                )
            case .accountDetail(let account):
                AccountDetailView(
                    viewModel: AccountDetailViewModel(
                        account: account,
                        accounts: viewModel.availableAccounts,
                        managedObjectContext: viewModel.managedObjectContext
                    )
                )
            }
        })
        .navigationTitle("Gasto")
        .toolbar {

            ToolbarItem {
                Image(systemName: "trash")
                    .tint(Color.red)
                    .onTapGesture {
                        showDeleteConfirmation = true
                    }
                    .confirmationDialog(
                        "Really?",
                        isPresented: $showDeleteConfirmation
                    ) {
                        Button("Si", role: .destructive) {
                            viewModel.onDelete()
                            showDeleteConfirmation = false
                            //                            isPresented = false
                        }
                        Button("No", role: .cancel) {}
                    }
            }

            if viewModel.expense == nil {
                ToolbarItem {
                    Text("Save")
#if os(iOS)
                        .bold()
#endif
                        .padding(8)
                        .background {
                            Color("Success")
                        }
                        .foregroundColor(
                            Color("TextActive"))
                        .cornerRadius(4)
                        .onTapGesture {
                            viewModel.onSave(shouldDimiss: true, forceSave: true)
                            //                        isPresented = false
                        }
                }
            }
        }

        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onTapGesture(perform: {
            titleIsFocused = false
            amountIsFocused = false
        })
        .onAppear{
            viewModel.availableCategories.enumerated().forEach { (index, c) in
                if c == viewModel.category {
                    selectedCategory = index
                }
            }
            viewModel.availableAccounts.enumerated().forEach { (index, c) in
                if c == viewModel.account {
                    selectedAccount = index
                }
            }
            amountIsFocused = viewModel.expense == nil
        }
        .onDisappear {
            viewModel.onSave()
        }

    }
}
