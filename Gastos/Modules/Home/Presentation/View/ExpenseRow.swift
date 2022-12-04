//
//  ExpenseRow.swift
//  Gastos
//
//  Created by Adam Teale on 30-11-22.
//

import SwiftUI

struct ExpenseRow: View {

    let expense: Expense
    let displayVertically: Bool

    var body: some View {
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
                displayVertically: displayVertically
            )
        }
    }
}
