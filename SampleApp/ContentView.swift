//
//  ContentView.swift
//  SampleApp
//
//  Created by Binh An Tran on 3/3/22.
//

import SwiftUI
import SDK

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, world!")
                .padding()
            Text(sdkString)
        }
    }
}
