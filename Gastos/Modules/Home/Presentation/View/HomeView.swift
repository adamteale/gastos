//
//  HomeView.swift
//  Gastos
//
//  Created by Adam Teale on 25-11-22.
//

import SwiftUI
import CoreData

struct HomeViewArgs {
    let viewModel: HomeViewModel
}

struct HomeView: View {

    @ObservedObject var viewModel: HomeViewModel
    @State var searchOn: Bool = false
    @FocusState private var searchIsFocused: Bool

    @Environment(\.dismiss) private var dismiss

    init(
        args: HomeViewArgs
    ) {
        self.viewModel = args.viewModel
    }

    var body: some View {

        NavigationStack(path: $viewModel.mainStack) {
            ZStack(alignment: .bottom) {
                VStack {
                    if searchOn {
                        HStack {
                            TextField(
                                "Search", text: $viewModel.searchTerm
                            )
                            .focused($searchIsFocused)
                            .onChange(of: viewModel.searchTerm) { newValue in
                                viewModel.onUpdate(searchTerm: newValue)
                            }
                            if !viewModel.searchTerm.isEmpty {
                                Image(systemName: "xmark.circle")
                                    .font(.system(size: 20))
                                    .onTapGesture {
                                        viewModel.onClearSearchTerm()
                                    }
                            }
                            Spacer()
                        }
                        .padding()
                    }

                    MonthPickerComponent(
                        viewModel: MonthPickerComponentViewModel(
                            selectedDate: viewModel.selectedDate,
                            onChangeCurrentDate: viewModel.onChangeCurrentDate
                        )
                    )
                    .frame(maxWidth: .infinity)

                    HStack(alignment: .center, spacing: 2) {
                        Text("$")
                            .font(.system(size: 30))
                            .fontWeight(.black)
                        Text(Formatters.currencyFormatterNoSymbol.string(for: viewModel.totalAmount) ?? "" )
                            .font(.system(size: 40))
                            .fontWeight(.black)
                    }

                    List {
                        ForEach(viewModel.expensesSections, id: \.dateFormatted) { section in
                            ExpensesSection(
                                title: section.dateFormatted,
                                expenses: section.expenses,
                                onEditItem: { expense in
                                    viewModel.onEditItem(expense)
                                },
                                deleteItems: { indexSet in
                                    if let first = indexSet.first {
                                        viewModel.deleteItems(objectID: section.expenses[first].objectID)

                                    }
                                }
                            )

                        }
                    }
#if os(iOS)
                    .listStyle(.grouped)
#endif
                }
                HStack {
                    Spacer()
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .tint(Color.white)
                        .padding()
                        .background {
                            Color.blue
                        }
                        .cornerRadius(40)
                        .onTapGesture {
                            viewModel.onAddExpense()
                        }

                }
                .padding()

            }
            .navigationDestination(for: HomeCoordinator.Scene.self, destination: { scene in
                switch scene {
                case .expenseDetail(let expense):
                    ExpenseDetailView(
                        args: ExpenseDetailViewArgs(
                            viewModel: ExpenseDetailViewModel(
                                args: ExpenseDetailViewModelArgs(
                                    expense: expense,
                                    categories: viewModel.categories,
                                    availableTags: viewModel.availableTags,
                                    availableAccounts: viewModel.accounts,
                                    managedObjectContext: viewModel.managedObjectContext,
                                    onSaveSuccess: {
                                        viewModel.onDidSave()
                                    },
                                    onSceneChange: viewModel.onSceneChange
                                )
                            )
                        )
                    )
                case .categoryDetail(let category):
                    CategoryDetailView(
                        viewModel: CategoryDetailViewModel(
                            category: category,
                            categories: viewModel.categories,
                            managedObjectContext: viewModel.managedObjectContext
                        ),
                        isPresented: $viewModel.isPresentingCategory
                    )

                case .tagDetail(let tag):
                    TagDetailView(
                        viewModel: TagDetailViewModel(
                            tag: tag,
                            tags: viewModel.availableTags,
                            managedObjectContext: viewModel.managedObjectContext
                        ),
                        isPresented: $viewModel.isPresentingTag
                    )
                case .accountDetail(let account):
                    AccountDetailView(
                        viewModel: AccountDetailViewModel(
                            account: account,
                            accounts: viewModel.accounts,
                            managedObjectContext: viewModel.managedObjectContext
                        ),
                        isPresented: $viewModel.isPresentingAccount
                    )
                }
            })
            .toolbar {
                ToolbarItem {
                    Button(action: viewModel.onAddAccount) {
                        Label("Add Account", systemImage: "creditcard")
                    }
                }
                ToolbarItem {
                    Button(action: viewModel.onAddTag) {
                        Label("Add Tag", systemImage: "tag")
                    }
                }
                ToolbarItem {
                    Button(action: viewModel.onAddCategory) {
                        Label("Add Category", systemImage: "rectangle.3.group")
                    }
                }
                ToolbarItem {
                    Button(action: toggleSearch) {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                }
            }
        }
        .onAppear{ viewModel.onRefresh() }
        .refreshable {
            viewModel.onRefresh()
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
        .sheet(isPresented: $viewModel.isPresentingAccount) {
            AccountDetailView(
                viewModel: AccountDetailViewModel(
                    account: viewModel.activeAccount,
                    accounts: viewModel.accounts,
                    managedObjectContext: viewModel.managedObjectContext
                ),
                isPresented: $viewModel.isPresentingAccount
            )
        }

    }

    private func toggleSearch() {
        searchOn.toggle()
        viewModel.onUpdate(searchTerm: "")
        searchIsFocused = true
    }
}
