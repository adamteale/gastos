//
//  ExpensesSection.swift
//  Gastos
//
//  Created by Adam Teale on 29-11-22.
//

import SwiftUI

import CoreData

struct ExpensesSection: View {
    var title: String
    var expenses: [Expense]
    var onEditItem: (Expense) -> Void
    var deleteItems: (IndexSet) -> Void

    var body: some View {
        Section(header: Text(title)) {
            ForEach(
                Array(expenses.enumerated()),
                id: \.offset
            ) { index, expense in
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
                    TagCloudView(
                        tags: Array(expense.tags as? Set<Tag> ?? Set<Tag>()),
                        currentSelection: Array(expense.tags as? Set<Tag> ?? Set<Tag>()),
                        onUpdate: {_ in},
                        onEditTag: {_ in},
                        displayVertically: true
                    )
                }
                .onTapGesture {
                    onEditItem(expense)
                }
            }
            .onDelete(perform: deleteItems)
        }
    }

}
