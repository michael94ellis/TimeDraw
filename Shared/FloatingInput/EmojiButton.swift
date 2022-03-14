//
//  EmojiButton.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/13/22.
//

import SwiftUI

struct EmojiButton: View {
    
    let numberOfEmojiColumns: Int = 5
    let emojiButtonWidth: Int = 45
    let emojiButtonHeight: Int = 40
    
    @State var isShowingEmojiPicker: Bool = false
    @State var emojiSelection: String = ""
    @EnvironmentObject var viewModel: ModifyCalendarItemViewModel
    
    func getRecentEmojis() -> [String] {
        guard let prefs = UserDefaults(suiteName: "com.apple.EmojiPreferences"),
              let defaults = prefs.dictionary(forKey: "EMFDefaultsKey"),
              let recents = defaults["EMFRecentsKey"] as? [String] else {
                  // No Recent Emojis
                  return ["No Recent Emojis"]
              }
        return recents
    }
    
    var emojiPopoverSize: CGSize {
        let emojiListCount = self.getRecentEmojis().count
        let emojiPopoverWidth = emojiListCount >= self.numberOfEmojiColumns ?
        self.emojiButtonWidth * self.numberOfEmojiColumns :
        emojiListCount * self.emojiButtonWidth
        let emojiPopoverHeight = (emojiListCount / self.numberOfEmojiColumns + emojiListCount % self.numberOfEmojiColumns) * self.emojiButtonHeight
        return CGSize(width: emojiPopoverWidth, height: emojiPopoverHeight)
    }
    
    var body: some View {
        PopoverButton(showPopover: self.$isShowingEmojiPicker,
                      popoverSize: self.emojiPopoverSize,
                      content: {
            Image("smile.face")
                .resizable()
                .frame(width: 25, height: 25)
                .gesture(TapGesture().onEnded({
                    withAnimation {
                        self.isShowingEmojiPicker.toggle()
                    }
                }))
        }, popoverContent: {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: self.numberOfEmojiColumns)) {
                ForEach(self.getRecentEmojis(), id: \.self) { emoji in
                    Button(emoji, action: {
                        self.viewModel.newItemTitle = "\(emoji) \(self.viewModel.newItemTitle)"
                        self.isShowingEmojiPicker.toggle()
                    })
                        .frame(width: CGFloat(self.emojiButtonWidth), height: CGFloat(self.emojiButtonHeight))
                }
            }
            .padding(.horizontal)
        })
            .padding(.leading, 12)
            .padding(.trailing, 5)
    }
}
