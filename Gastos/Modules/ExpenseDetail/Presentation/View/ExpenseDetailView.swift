//
//  ExpenseDetailView.swift
//  Gastos
//
//  Created by Adam Teale on 25-11-22.
//

import Foundation
import SwiftUI

struct ExpenseDetailView: View {

    @ObservedObject private var viewModel: ExpenseDetailViewModel
    @Binding var isPresented: Bool
    @State private var selectedCategory: Int
    @State private var selectedAccount: Int

    @FocusState private var titleIsFocused: Bool
    @FocusState private var amountIsFocused: Bool

    init(
        viewModel: ExpenseDetailViewModel,
        isPresented: Binding<Bool>
    ) {
        self.viewModel = viewModel
        self._isPresented = isPresented // "_" how dumb!
        selectedCategory = 0
        selectedAccount = 0
    }

    var body: some View {

        ScrollView {

            HStack {
                Button(action: {
                    if viewModel.expense == nil {
                        isPresented = false
                    } else {
                        viewModel.onSave {
                            isPresented = false
                        }
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .tint(Color("Text"))
                        .font(.system(size: 20.0, weight: .semibold))
                }
                Spacer()
                    .frame(maxWidth:.infinity)
            }
            .padding(.bottom)

            VStack (spacing: 16) {
                HStack(alignment: .center) {
                    Spacer()
                    HStack {
                        Text("$")
                            .font(.system(size: 30))
                            .fontWeight(.heavy)
                            .frame(alignment:.trailing)
                        TextField(
                            "0",
                            value: $viewModel.amount,
                            formatter: Formatters.currencyFormatterNoSymbol
                        )
                        .multilineTextAlignment(.leading)
#if os(iOS)
                        .fontWeight(.heavy)
                        .font(.system(size: 60))
                        .keyboardType(.decimalPad)
#endif
                        .focused($amountIsFocused)
                        .onSubmit {
                            amountIsFocused = false
                            titleIsFocused = true
                        }
                    }
                    Spacer()
                }

#if os(iOS)
                TextField(
                    "Desc",
                    text: $viewModel.title,
                    axis: .vertical
                )
                .multilineTextAlignment(.leading)
                .font(.system(size: 40))
                .focused($titleIsFocused)
                .onSubmit {
                    titleIsFocused = false
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

                    Button(action: {
                        viewModel.onAddAccount()
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 30.0, weight: .semibold))
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
                    onEditTag: viewModel.onEditAccount
                )

                HStack {
                    Text("Category")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button(action: {
                        viewModel.onAddCategory()
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 30.0, weight: .semibold))
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
                    onEditTag: viewModel.onEditCategory
                )

                HStack{
                Text("Tags")
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Button(action: {
                        viewModel.onAddTag()
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 30.0, weight: .semibold))
                    }
                }
                TagCloudView(
                    tags: viewModel.availableTags,
                    currentSelection: Array(viewModel.tags),
                    onUpdate: viewModel.onUpdateTag,
                    onEditTag: viewModel.onEditTag
                )

            }

        }
        .padding()
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
        .sheet(isPresented: $viewModel.isPresentingCategory) {
            CategoryDetailView(
                viewModel: CategoryDetailViewModel(
                    category: viewModel.activeCategory,
                    categories: viewModel.availableCategories,
                    managedObjectContext: viewModel.managedObjectContext
                ),
                isPresented: $viewModel.isPresentingCategory
            )
        }
        .sheet(isPresented: $viewModel.isPresentingTag) {
            TagDetailView(
                viewModel: TagDetailViewModel(
                    tag: viewModel.activeTag,
                    tags: viewModel.availableTags,
                    managedObjectContext: viewModel.managedObjectContext
                ),
                isPresented: $viewModel.isPresentingTag
            )
        }
        .sheet(isPresented: $viewModel.isPresentingAccount) {
            AccountDetailView(
                viewModel: AccountDetailViewModel(
                    account: viewModel.activeAccount,
                    accounts: viewModel.availableAccounts,
                    managedObjectContext: viewModel.managedObjectContext
                ),
                isPresented: $viewModel.isPresentingTag
            )
        }
        .ignoresSafeArea(edges: .bottom)
    }

}

