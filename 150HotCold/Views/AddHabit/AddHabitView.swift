//
//  AddHabitView.swift
//  150HotCold
//

import SwiftUI

struct AddHabitView: View {
    @ObservedObject var viewModel: HotColdViewModel

    var body: some View {
        HabitEditorView(viewModel: viewModel, editing: nil)
    }
}
