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
                Label("", systemImage: "arrow.backward")
                    .font(.system(size: 20))
            }
            Spacer()
                .frame(maxWidth:.infinity)
        }
        .padding()

        ScrollView {
            VStack (spacing: 16) {
                TextField(
                    "Title",
                    text: $viewModel.title,
                    axis: .vertical
                )
                .multilineTextAlignment(.center)
                .font(.system(size: 40))
#if os(iOS)
                .fontWeight(.semibold)
#endif
                .padding()
                .focused($titleIsFocused)
                .onSubmit {
                    titleIsFocused = false
                    amountIsFocused = true
                }

                TextField(
                    "",
                    value: $viewModel.amount,
                    formatter: Formatters.currencyFormatter
                )
                .multilineTextAlignment(.center)
#if os(iOS)
                .fontWeight(.heavy)
                .font(.system(size: 50))
                .keyboardType(.decimalPad)
#endif
                .focused($amountIsFocused)
                .onSubmit {
                    amountIsFocused = false
                }

                DatePicker(
                    "fecha",
                    selection: $viewModel.date,
                    displayedComponents: [.date]
                )
                .labelsHidden()

                Picker(selection: $selectedAccount, label: Text("Account")) {
                    ForEach(0..<viewModel.accounts.count, id: \.self) { index in
                        Text(viewModel.accounts[index].name ?? "-")
                            .minimumScaleFactor(0.2)
                            .font(.system(size: 30))
                            .fontWeight(.semibold)
                            .tag(index)
                    }
                }
                .frame(height: 140)
                .onChange(of: selectedAccount) { index in
                    viewModel.onUpdateAccount(atIndex: index)
                }
#if os(iOS)
                .pickerStyle(WheelPickerStyle())
#endif

                HStack {
                    Button(action: {
                        viewModel.onAddCategory()
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 30.0, weight: .semibold))
                    }
                    Picker(selection: $selectedCategory, label: Text("Category")) {
                        ForEach(0..<viewModel.categories.count, id: \.self) { index in
                            Text(viewModel.categories[index].name ?? "-")
                                .minimumScaleFactor(0.2)
                                .font(.system(size: 30))
                                .fontWeight(.semibold)
                                .tag(index)
                        }
                    }
                    .frame(height: 140)
                    .onChange(of: selectedCategory) { index in
                        viewModel.onUpdateCategory(atIndex: index)
                    }
#if os(iOS)
                    .pickerStyle(WheelPickerStyle())
#endif
                }

                HStack{

                    Button(action: {
                        viewModel.onAddTag()
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 30.0, weight: .semibold))
                    }

                    LazyHGrid (rows: [GridItem(.adaptive(minimum: 200))], spacing: 8) {
                        ForEach(Array(viewModel.availableTags)) { tag in
                            Button {
                                viewModel.onUpdate(tag: tag)
                            } label: {
                                Text(tag.name ?? "-")
                                    .font(.system(size: 20))
                                    .bold()
                                    .padding(8)
                                    .foregroundColor(
                                        viewModel.tags.contains(where: { aTag in
                                            tag.objectID == aTag.objectID
                                        }) ?
                                        Color.white : Color.blue
                                    )
                                    .background {
                                        viewModel.tags.contains(where: { aTag in
                                            tag.objectID == aTag.objectID
                                        }) ?
                                        Color.green.opacity(0.3) : Color.gray.opacity(0.1)
                                    }
                                    .cornerRadius(4)
                            }

                        }
                    }
                    .frame(maxWidth: .infinity)

                }

                Button(action: {
                    viewModel.onSave {
                        isPresented = false
                    }
                }) {
                    Text("Save")
                        .font(.system(size: 30))
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .foregroundColor(
                    Color.white
                )
                .background {
                    Color.blue.opacity(0.3)
                }
                .cornerRadius(8)

            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .onTapGesture(perform: {
            titleIsFocused = false
            amountIsFocused = false
        })
        .onAppear{
            viewModel.categories.enumerated().forEach { (index, c) in
                if c == viewModel.category {
                    selectedCategory = index
                }
            }
            titleIsFocused = viewModel.expense == nil
        }
        .sheet(isPresented: $viewModel.isPresentingCategory) {
            CategoryDetailView(
                viewModel: CategoryDetailViewModel(
                    category: viewModel.activeCategory,
                    categories: viewModel.categories,
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
    }

}

