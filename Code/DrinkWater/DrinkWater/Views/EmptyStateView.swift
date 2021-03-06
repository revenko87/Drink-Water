//  Created by Revenko on 7/7/20.
//  Copyright © 202 Revenko. All rights reserved.

import SwiftUI

/// Показывает пустое состояние, когда у пользователя нет записей о напитках
struct EmptyStateView: View {
    var body: some View {
        GeometryReader { reader in
            VStack {
                Image("empty_view_image")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 150)
                Text("Нет истории").font(.system(size: 30)).bold()
                Text("У Вас нет никаких\nзаписей о действиях")
                    .foregroundColor(.secondary)
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: UIScreen.main.bounds.width,
                   height: (UIScreen.main.bounds.height - reader.frame(in: .global).origin.y) - 50)
        }
    }
}
