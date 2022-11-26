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

    @FocusState private var titleIsFocused: Bool
    @FocusState private var amountIsFocused: Bool

    init(
        viewModel: ExpenseDetailViewModel,
        isPresented: Binding<Bool>
    ) {
        self.viewModel = viewModel
        self._isPresented = isPresented // "_" how dumb!
        selectedCategory = 0
        titleIsFocused = false
    }

    var body: some View {
            VStack (spacing: 16) {
                HStack {
                    Button(action: {
                        viewModel.onSave {
                            isPresented = false
                        }
                    }) {
                        Label("", systemImage: "arrow.backward")
                            .font(.system(size: 20))
                    }
                    Spacer()
                        .frame(maxWidth:.infinity)
                }

                TextField("Title", text: $viewModel.title)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 40))
#if os(iOS)
                    .fontWeight(.semibold)
#endif
                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                    .focused($titleIsFocused)
                    .onSubmit {
                        titleIsFocused = false
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
                    "Fecha",
                    selection: $viewModel.date,
                    displayedComponents: [.date]
                )
                .labelsHidden()


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
                                .font(.system(size: 30))
                                .fontWeight(.semibold)
                                .tag(index)
                        }
                    }.onChange(of: selectedCategory) { index in
                        viewModel.onUpdateCategory(atIndex: index)
                    }
#if os(iOS)
                    .pickerStyle(WheelPickerStyle())
#endif
                }

                HStack {
                    Button(action: {
                        viewModel.onAddTag()
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 30.0, weight: .semibold))
                    }

                    LazyVGrid (columns: [GridItem(.adaptive(minimum: 200))], spacing: 16) {
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

                    Spacer()
#if os(iOS)
                    .pickerStyle(WheelPickerStyle())
#endif
                }
                .frame(maxWidth: .infinity)

                Spacer()

//                if viewModel.expense != nil {
                    // Hide save button when showing an existing Expense as it will "auto save" in the viewmodel
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
//                }
            }

        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .onAppear{
            viewModel.categories.enumerated().forEach { (index, c) in
                if c == viewModel.category {
                    selectedCategory = index
                }
            }
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

