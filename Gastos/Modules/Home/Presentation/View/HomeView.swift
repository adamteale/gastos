//
//  HomeView.swift
//  Gastos
//
//  Created by Adam Teale on 25-11-22.
//

import SwiftUI

struct HomeView: View {

    @ObservedObject var viewModel: HomeViewModel
    @State var searchOn: Bool = false
    @FocusState private var searchIsFocused: Bool

    var body: some View {
        NavigationView {
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
                            Button(action: viewModel.onClearSearchTerm) {
                                Label("", systemImage: "xmark.circle")
                                    .font(.system(size: 20))
                            }
                        }
                        Spacer()
                    }
                    .padding()
                }

                Text(Formatters.currencyFormatter.string(for: viewModel.totalAmount) ?? "")
                    .font(.system(size: 40))
                    .fontWeight(.black)
                    .padding(4)
                VStack {

                List {
                    ForEach(
                        Array(viewModel.expensesSections).sorted(by: { $0.key > $1.key }), id: \.key
                    ) { key, value in
                        ExpensesSection(
                            title: key,
                            expenses: value,
                            onEditItem: { index in
                                viewModel.onEditItem(objectID: value[index].objectID)
                            },
                            deleteItems: { indexSet in
                                if let first = indexSet.first {
                                    viewModel.deleteItems(objectID: value[first].objectID)
                                }
                            }
                        )
                    }
                }
                    Button(action: viewModel.onAddExpense) {
                        Label("", systemImage: "plus")
                            .font(.system(size: 50))
                            .fontWeight(.black)
                    }

                }
                .toolbar {
#if os(iOS)
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
#endif
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

        }
        .onAppear{ viewModel.onRefresh() }
        .sheet(isPresented: $viewModel.isPresentingExpense) {
            ExpenseDetailView(
                viewModel: ExpenseDetailViewModel(
                    expense: viewModel.activeExpense,
                    categories: viewModel.categories,
                    availableTags: viewModel.availableTags,
                    availableAccounts: viewModel.accounts,
                    managedObjectContext: viewModel.managedObjectContext
                ),
                isPresented: $viewModel.isPresentingExpense
            )
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

struct ExpensesSection: View {
    var title: String
    var expenses: [Expense]
    var onEditItem: (Int) -> Void
    var deleteItems: (IndexSet) -> Void

    var body: some View {
        Section(header: Text(title)) {
            ForEach(
                Array(
                    expenses.enumerated()),
                id: \.offset
            ) { index, expense in
                Button {
                    onEditItem(index)
                } label: {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(expense.title ?? "")
                            .font(.system(size: 24))
                            .fontWeight(.semibold)
                        Text(expense.category?.name ?? "")
                            .font(.system(size: 20))
                            .fontWeight(.medium)
                        Text("$\(String(format: "%.2f", expense.amount))")
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                        if let date = Formatters.onlyDate.string(for: expense.date ?? Date()) {
                            Text(date)
                        }

                        if expense.tags?.count ?? 0 > 0 {
                            TagsComponent(tags: Array(expense.tags as? Set<Tag> ?? Set<Tag>()))
                        }
                    }
                }
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
                        Color.green.opacity(0.3)
                    }
                    .cornerRadius(4)
            }
        }
    }

}


private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

