//
//  AccountDetailView.swift
//  Gastos
//
//  Created by Adam Teale on 25-11-22.
//

import Foundation
import SwiftUI

struct AccountDetailView: View {

    @ObservedObject private var viewModel: AccountDetailViewModel
    @Binding var isPresented: Bool
    @FocusState private var titleIsFocused: Bool
    @State private var showDeleteConfirmation = false

    init(
        viewModel: AccountDetailViewModel,
        isPresented: Binding<Bool>
    ) {
        self.viewModel = viewModel
        self._isPresented = isPresented // "_" how dumb!
        self.titleIsFocused = true
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                            .tint(Color("Text"))
                            .font(.system(size: 20.0, weight: .semibold))
                            .onTapGesture {
                                isPresented = false
                            }
                    Spacer()
                        .frame(maxWidth:.infinity)
                    if viewModel.account != nil {
                        Image(systemName: "trash")
                            .tint(Color.red)
                            .onTapGesture {
                                showDeleteConfirmation = true
                            }
                            .onTapGesture {
                                showDeleteConfirmation = true
                            }
                        .confirmationDialog(
                            "Really?",
                            isPresented: $showDeleteConfirmation
                        ) {
                            Button("Si", role: .destructive) {
                                viewModel.onDelete()
                                showDeleteConfirmation = false
                            }
                            Button("No", role: .cancel) {}
                        }
                    }
                }
                Spacer()
                TextField("Name", text: $viewModel.name).onSubmit {
                    viewModel.onUpdate {
                        isPresented = false
                    }
                }
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
                
                if viewModel.alreadyExists {
                    Text("already exists!")
                        .font(.system(size: 40))
                        .foregroundColor(.red)

                }
                Spacer()


                List {
                    ForEach(
                        Array(
                            viewModel.accounts.enumerated()),
                        id: \.offset
                    ) { index, account in
                        VStack(alignment: .leading) {
                            Text(account.name ?? "")
                                .font(.system(size: 20))
                                .fontWeight(.medium)
                        }
                        .onTapGesture {
                            viewModel.onEditItem(at: index)
                        }
                    }
                    .onDelete(perform: viewModel.deleteItems)
                }
            }

            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
            .onAppear{
                titleIsFocused = true
            }

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

}

