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

                MonthPickerComponent(
                    viewModel: MonthPickerComponentViewModel(
                        selectedDate: viewModel.selectedDate,
                        onChangeCurrentDate: viewModel.onChangeCurrentDate
                    )
                )

                Text(Formatters.currencyFormatter.string(for: viewModel.totalAmount) ?? "")
                    .font(.system(size: 40))
                    .fontWeight(.black)
                    .padding(4)

                ZStack(alignment: .bottom) {
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
                    HStack {
                        Spacer()
                        Button(action: viewModel.onAddExpense) {
                            Group {
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .tint(Color.white)
                            }
                                .frame(width: 50, height: 50)
                                .padding()
                                .background {
                                    Color.blue
                                }
                                .cornerRadius(41)

                        }
                    }
                    .padding()
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
                    VStack(alignment: .leading, spacing: 2) {
                        Text(expense.title ?? "")
                            .font(.system(size: 24))
                            .fontWeight(.heavy)
                        Text(Formatters.currencyFormatter.string(for: expense.amount) ?? "")
                            .font(.system(size: 24))
                            .fontWeight(.black)
                        Text(expense.category?.name ?? "")
                            .font(.system(size: 20))
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
                }
            }
            .onDelete(perform: deleteItems)
        }
    }

}


final class MonthPickerComponentViewModel: ObservableObject {

    private let onChangeCurrentDate: (Date) -> Void
    let formatter = DateFormatter()

    private(set) var selectedDate: Date

    init(
        selectedDate: Date,
        onChangeCurrentDate: @escaping (Date) -> Void
    ) {
        self.onChangeCurrentDate = onChangeCurrentDate
        self.selectedDate = selectedDate
    }


    func onMonthSelected(month: String) {
        if let index = formatter.shortMonthSymbols.firstIndex(where: {$0 == month}) {
            var dateComponents = Calendar.current.dateComponents([.month, .day, .year], from: selectedDate)
            dateComponents.month = index + 1
            if let newdate = Calendar.current.date(from: dateComponents) {
                onChangeCurrentDate(newdate)
            }
        }
    }

    func nextYear() {
        var dateComponents = Calendar.current.dateComponents([.month, .day, .year], from: selectedDate)
        dateComponents.year = (dateComponents.year ?? 0) + 1
        if let newdate = Calendar.current.date(from: dateComponents) {
            onChangeCurrentDate(newdate)
        }
    }

    func previousYear() {
        var dateComponents = Calendar.current.dateComponents([.month, .day, .year], from: selectedDate)
        dateComponents.year = (dateComponents.year ?? 0) - 1
        if let newdate = Calendar.current.date(from: dateComponents) {
            onChangeCurrentDate(newdate)
        }
    }
}


struct MonthPickerComponent: View {

    private let calendar = Calendar.current
    private let months: [String] = Calendar.current.shortMonthSymbols
    private var years: CountableRange<Int> = CountableRange<Int>(uncheckedBounds: (lower: 0, upper: 1))
    private let currentMonthFormatted: String
    private let currentYearFormatted: String

    @ObservedObject private var viewModel: MonthPickerComponentViewModel

    init(viewModel: MonthPickerComponentViewModel) {
        self.viewModel = viewModel
        let start = calendar.component(.year, from: Date.distantPast)
        let future = calendar.component(.year, from: Date.distantFuture)
        years = CountableRange<Int>(uncheckedBounds: (lower: start, upper: future))

        currentMonthFormatted = Formatters.onlyMonth.string(for: viewModel.selectedDate) ?? ""
        currentYearFormatted = Formatters.onlyYear.string(for: viewModel.selectedDate) ?? ""
    }

    var body: some View {

        VStack {
            HStack {
                Button {
                    viewModel.previousYear()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .frame(width: 24.0)
                }

                Text(currentYearFormatted)
                    .foregroundColor(.blue).bold()
                    .transition(.move(edge: .trailing))

                Spacer()
                Button {
                    viewModel.nextYear()
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                        .frame(width: 24.0)
                }
            }
            .padding(.all, 8)
            .background(Color.clear)

            ScrollView(.horizontal) {
                ScrollViewReader { value in
                    HStack() {
                        ForEach(months, id: \.self) { item in
                            Button {
                                viewModel.onMonthSelected(month: item)
                            } label: {
                                Text(item)
                                    .foregroundColor(
                                        item == currentMonthFormatted ? .white : .black
                                    )
                                    .padding(8)
                                    .background(content: {
                                        item == currentMonthFormatted ? Color.blue : Color.clear
                                    })
                                    .cornerRadius(4)
                                    .id(item)
                            }

                        }
                    }
                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 8))
                    .onAppear{
                        value.scrollTo(currentMonthFormatted)
                    }
                }
            }
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

