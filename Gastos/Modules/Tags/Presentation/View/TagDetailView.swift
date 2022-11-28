//
//  TagDetailView.swift
//  Gastos
//
//  Created by Adam Teale on 25-11-22.
//

import Foundation
import SwiftUI

struct TagDetailView: View {

    @ObservedObject private var viewModel: TagDetailViewModel
    @Binding var isPresented: Bool
    @FocusState private var titleIsFocused: Bool

    init(
        viewModel: TagDetailViewModel,
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
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .tint(Color("Text"))
                            .font(.system(size: 20.0, weight: .semibold))
                    }
                    Spacer()
                        .frame(maxWidth:.infinity)
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
                            viewModel.tags.enumerated()),
                        id: \.offset
                    ) { index, tag in
                        VStack(alignment: .leading) {
                            Text(tag.name ?? "")
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
        .sheet(isPresented: $viewModel.isPresentingTag) {
            TagDetailView(
                viewModel: TagDetailViewModel(
                    tag: viewModel.activeTag,
                    tags: viewModel.tags,
                    managedObjectContext: viewModel.managedObjectContext
                ),
                isPresented: $viewModel.isPresentingTag
            )
        }

    }

}

