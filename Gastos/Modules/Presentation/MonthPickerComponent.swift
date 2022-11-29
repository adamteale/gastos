//
//  MonthPickerComponent.swift
//  Gastos
//
//  Created by Adam Teale on 28-11-22.
//

import SwiftUI

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
                            Text(item)
                                .foregroundColor(
                                    item == currentMonthFormatted ? Color("TextActive") : Color("Text")
                                )
                                .padding(8)
                                .background(content: {
                                    item == currentMonthFormatted ? Color("Neutral") : Color.clear
                                })
                                .cornerRadius(4)
                                .id(item)
                                .onTapGesture {
                                    viewModel.onMonthSelected(month: item)
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
