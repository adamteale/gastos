//
//  TCloudView.swift
//  Gastos
//
//  Created by Adam Teale on 27-11-22.
//

import SwiftUI

struct TagCloudView<T: TagCloudable>: View {

    @State private var totalHeight = CGFloat.zero       // << variant for ScrollView/List
                         //    = CGFloat.infinity   // << variant for VStack

    private var tags: [T]
    private var currentSelection: [T]?
    private var onUpdate: (T) -> Void
    private var onEditTag: (T) -> Void

    private let displayVertically: Bool

    init(
        tags: [T],
        currentSelection: [T]?,
        onUpdate: @escaping (T) -> Void,
        onEditTag: @escaping (T) -> Void,
        displayVertically: Bool
    ) {
        self.tags = tags
        self.currentSelection = currentSelection
        self.onUpdate = onUpdate
        self.onEditTag = onEditTag
        self.displayVertically = displayVertically
    }

    var body: some View {
        if (displayVertically) {
            VStack {
                GeometryReader { geometry in
                    self.generateContent(in: geometry)
                }
            }
            .frame(height: totalHeight)// << variant for ScrollView/List
        } else {
            VStack {
                GeometryReader { geometry in
                    self.generateContent(in: geometry)
                }
            }
            .frame(maxHeight: totalHeight) // << variant for VStack
        }
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.tags, id: \.self) { tag in
                self.item(for: tag)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if tag == self.tags.last! {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if tag == self.tags.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }.background(viewHeightReader($totalHeight))
    }

    private func item(for tag: T) -> some View {
            Text(tag.name ?? "-")
                .font(.system(size: 20))
                .bold()
                .padding(8)
                .foregroundColor(
                    (currentSelection ?? []).contains(where: { aT in
                        tag.objectID == aT.objectID
                    }) ?
                    Color.white : Color("Text")
                )
                .background {
                    (currentSelection ?? []).contains(where: { aT in
                        tag.objectID == aT.objectID
                    }) ?
                    Color("Success").opacity(0.5) : Color.clear
                }
                .cornerRadius(4)
                .onTapGesture {
                    onUpdate(tag)
                }
                .onLongPressGesture {
                    onEditTag(tag)
                }
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}
