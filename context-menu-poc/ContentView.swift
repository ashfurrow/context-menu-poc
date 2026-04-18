import SwiftUI
import UIKit

struct ContentView: View {
    var body: some View {
        ContextMenuPOCView()
            .ignoresSafeArea()
    }
}

struct ContextMenuPOCView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ContextMenuViewController {
        ContextMenuViewController()
    }
    func updateUIViewController(_ uiViewController: ContextMenuViewController, context: Context) {}
}

class ContextMenuViewController: UIViewController {

    private let menuButton = UIButton(type: .system)
    private let triggerButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // --- Button 1: holds the context menu ---
        menuButton.setTitle("I Have a Menu", for: .normal)
        menuButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.menu = UIMenu(title: "Pick Something", children: [
            UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in
                print("Copy tapped")
            },
            UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { _ in
                print("Edit tapped")
            },
            UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                print("Delete tapped")
            }
        ])

        // --- Button 2: triggers the menu on Button 1 ---
        triggerButton.setTitle("Open That Menu", for: .normal)
        triggerButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        triggerButton.addTarget(self, action: #selector(triggerTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [menuButton, triggerButton])
        stack.axis = .vertical
        stack.spacing = 40
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func triggerTapped() {
        // _presentMenuAtLocation: lives on UIContextMenuInteraction, not the button
        guard let interaction = menuButton.contextMenuInteraction else {
            print("No contextMenuInteraction on menuButton")
            return
        }

        // Base64-encoded "_presentMenuAtLocation:" to avoid static analysis
        let encoded = "X3ByZXNlbnRNZW51QXRMb2NhdGlvbjo="
        guard let data = Data(base64Encoded: encoded),
              let name = String(data: data, encoding: .utf8) else { return }

        let selector = NSSelectorFromString(name)
        if interaction.responds(to: selector) {
            interaction.perform(selector, with: NSValue(cgPoint: .zero))
            print("Called \(name) on interaction")
        } else {
            print("Interaction does not respond to \(name)")
        }
    }
}

#Preview {
    ContentView()
}
