//
//  HomeView.swift
//  Gastos
//
//  Created by Adam Teale on 25-11-22.
//

import SwiftUI
import CoreData

struct HomeView: View {

    @ObservedObject var viewModel: HomeViewModel
    @State var searchOn: Bool = false
    @FocusState private var searchIsFocused: Bool

    var body: some View {
        Group {
            NavigationView {
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
                        .padding(4)

                        List {
                            ForEach(viewModel.expensesSections, id: \.dateFormatted) { section in
                                ExpensesSection(
                                    title: section.dateFormatted,
                                    expenses: section.expenses,
                                    onEditItem: { index in
                                        viewModel.onEditItem(objectID: section.expenses[index].objectID)
                                    },
                                    deleteItems: { indexSet in
                                        if let first = indexSet.first {
                                            viewModel.deleteItems(objectID: section.expenses[first].objectID)
                                        }
                                    },
                                    categories: viewModel.categories,
                                    availableTags: viewModel.availableTags,
                                    availableAccounts: viewModel.accounts,
                                    managedObjectContext: viewModel.managedObjectContext,
                                    activeExpense: viewModel.activeExpense
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
                .toolbar {
//#if os(iOS)
//                    ToolbarItem(placement: .navigationBarLeading) {
//                        EditButton()
//                    }
//#endif
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
            .refreshable {
                viewModel.onRefresh()
            }
        }
        .onAppear{ viewModel.onRefresh() }

        //        .sheet(isPresented: $viewModel.isPresentingExpense) {
        //            ExpenseDetailView(
        //                viewModel: ExpenseDetailViewModel(
        //                    expense: viewModel.activeExpense,
        //                    categories: viewModel.categories,
        //                    availableTags: viewModel.availableTags,
        //                    availableAccounts: viewModel.accounts,
        //                    managedObjectContext: viewModel.managedObjectContext
        //                ),
        //                isPresented: $viewModel.isPresentingExpense
        //            )
        //        }
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

struct ExpensesSection: View {
    var title: String
    var expenses: [Expense]
    var onEditItem: (Int) -> Void
    var deleteItems: (IndexSet) -> Void

    var categories: [Category]
    var availableTags: [Tag]
    var availableAccounts: [Account]
    var managedObjectContext: NSManagedObjectContext

    @ObservedObject var activeExpense: ActiceExpense
    @State var isPresented = false

    var body: some View {

        Section(header: Text(title)) {

            ForEach(
                Array(expenses.enumerated()),
                id: \.offset
            ) { index, expense in

                NavigationLink(
                    destination: ExpenseDetailView(
                        viewModel: ExpenseDetailViewModel(
                            expense: expense,
                            categories: categories,
                            availableTags: availableTags,
                            availableAccounts: availableAccounts,
                            managedObjectContext: managedObjectContext
                        )
                    ),
                    isActive: $isPresented,
                    label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(expense.title ?? "")
                                .multilineTextAlignment(.leading)
                                .font(.system(size: 18))
#if os(iOS)
                                .fontWeight(.bold)
#endif
                            HStack(alignment: .center, spacing: 0) {
                                Text("$")
                                    .font(.system(size: 20))
                                    .fontWeight(.black)
                                Text(Formatters.currencyFormatterNoSymbol.string(for: expense.amount) ?? "")
                                    .font(.system(size: 30))
                                    .fontWeight(.black)
                            }
                            Text(expense.category?.name ?? "")
                                .font(.system(size: 18))
                                .fontWeight(.medium)
                            Text(expense.account?.name ?? "")
                                .font(.system(size: 14))
                                .fontWeight(.medium)
                                .padding(4)
                                .background {
                                    Color.blue.opacity(0.3)
                                }
                                .cornerRadius(4)
                            if expense.tags?.count ?? 0 > 0 {
                                TagsComponent(tags: Array(expense.tags as? Set<Tag> ?? Set<Tag>()))
                            }
                        }
                        .onTapGesture {
                            print("me", expense.title)
                        }

                    }
                )

            }
            .onDelete(perform: deleteItems)
        }
    }

}



struct TagsComponent: View {
    let tags: [Tag]

    var body: some View {

        LazyHGrid(rows: [GridItem(.adaptive(minimum: 80))], spacing: 4) {

            ForEach(Array(tags)) { tag in
                Text(tag.name ?? "")
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                    .padding(4)
                    .background {
                        Color("Success").opacity(0.3)
                    }
                    .cornerRadius(4)
            }
        }
    }

}
