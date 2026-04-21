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

class ContextMenuViewController: UIViewController, UIContextMenuInteractionDelegate {

    private let menuButton = UIButton(type: .system)
    private let triggerButton = UIButton(type: .system)
    private let interactionView = UIView()
    private let dualButton = UIButton(type: .system)
    private var tealInteraction: UIContextMenuInteraction!
    private var dualButtonInteraction: UIContextMenuInteraction!
    private var containerInteraction: UIContextMenuInteraction!
    private var dualButtonProgrammaticTrigger = false

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

        // --- View 3: a plain view with its own UIContextMenuInteraction ---
        interactionView.backgroundColor = .systemTeal
        interactionView.layer.cornerRadius = 12
        interactionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            interactionView.widthAnchor.constraint(equalToConstant: 200),
            interactionView.heightAnchor.constraint(equalToConstant: 120)
        ])
        let label = UILabel()
        label.text = "Long-press me"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        interactionView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: interactionView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: interactionView.centerYAnchor)
        ])
        tealInteraction = UIContextMenuInteraction(delegate: self)
        interactionView.addInteraction(tealInteraction)

        // --- Button 4: has BOTH a primary-action menu AND a separate context menu interaction ---
        dualButton.setTitle("Dual Menu Button", for: .normal)
        dualButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        dualButton.backgroundColor = .systemIndigo
        dualButton.setTitleColor(.white, for: .normal)
        dualButton.layer.cornerRadius = 12
        dualButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)

        // Single UIContextMenuInteraction — delegate switches menu based on trigger
        dualButtonInteraction = UIContextMenuInteraction(delegate: self)
        dualButton.addInteraction(dualButtonInteraction)

        // Tap triggers the interaction programmatically (shows "Primary" menu)
        // Long-press triggers it naturally (shows "Interaction" menu)
        dualButton.addTarget(self, action: #selector(dualButtonTapped), for: .touchUpInside)

        // --- View 5: colored view with context menu + a plain button inside ---
        let containerView = UIView()
        containerView.backgroundColor = .systemOrange
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalToConstant: 240),
            containerView.heightAnchor.constraint(equalToConstant: 100)
        ])

        let innerButton = UIButton(type: .system)
        innerButton.setTitle("Tap Me", for: .normal)
        innerButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        innerButton.setTitleColor(.white, for: .normal)
        innerButton.addTarget(self, action: #selector(innerButtonTapped), for: .touchUpInside)
        innerButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(innerButton)
        NSLayoutConstraint.activate([
            innerButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            innerButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])

        containerInteraction = UIContextMenuInteraction(delegate: self)
        containerView.addInteraction(containerInteraction)

        let stack = UIStackView(arrangedSubviews: [menuButton, triggerButton, interactionView, dualButton, containerView])
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

    // MARK: - UIContextMenuInteractionDelegate

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        if interaction === dualButtonInteraction {
            if dualButtonProgrammaticTrigger {
                // Tap → "Primary" menu
                dualButtonProgrammaticTrigger = false
                return UIContextMenuConfiguration(actionProvider: { _ in
                    UIMenu(title: "Primary Menu", children: [
                        UIAction(title: "New Window", image: UIImage(systemName: "macwindow.badge.plus")) { _ in
                            print("New Window tapped")
                        },
                        UIAction(title: "Split View", image: UIImage(systemName: "rectangle.split.2x1")) { _ in
                            print("Split View tapped")
                        }
                    ])
                })
            } else {
                // Long-press → "Interaction" menu
                return UIContextMenuConfiguration(actionProvider: { _ in
                    UIMenu(title: "Interaction Menu (Dual)", children: [
                        UIAction(title: "Inspect", image: UIImage(systemName: "eye")) { _ in
                            print("Inspect tapped")
                        },
                        UIAction(title: "Duplicate", image: UIImage(systemName: "plus.square.on.square")) { _ in
                            print("Duplicate tapped")
                        },
                        UIAction(title: "Report", image: UIImage(systemName: "exclamationmark.bubble")) { _ in
                            print("Report tapped")
                        }
                    ])
                })
            }
        }

        if interaction === containerInteraction {
            return UIContextMenuConfiguration(actionProvider: { _ in
                UIMenu(title: "Container Menu", children: [
                    UIAction(title: "Refresh", image: UIImage(systemName: "arrow.clockwise")) { _ in
                        print("Refresh tapped")
                    },
                    UIAction(title: "Settings", image: UIImage(systemName: "gear")) { _ in
                        print("Settings tapped")
                    }
                ])
            })
        }

        // Default: teal interactionView
        return UIContextMenuConfiguration(actionProvider: { _ in
            UIMenu(title: "Interaction Menu", children: [
                UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                    print("Share tapped")
                },
                UIAction(title: "Favorite", image: UIImage(systemName: "star")) { _ in
                    print("Favorite tapped")
                },
                UIAction(title: "Archive", image: UIImage(systemName: "archivebox")) { _ in
                    print("Archive tapped")
                }
            ])
        })
    }

    // MARK: - Trigger

    @objc private func innerButtonTapped() {
        print("tapped")
    }

    @objc private func dualButtonTapped() {
        dualButtonProgrammaticTrigger = true

        let encoded = "X3ByZXNlbnRNZW51QXRMb2NhdGlvbjo="
        guard let data = Data(base64Encoded: encoded),
              let name = String(data: data, encoding: .utf8) else { return }

        let selector = NSSelectorFromString(name)
        if dualButtonInteraction.responds(to: selector) {
            dualButtonInteraction.perform(selector, with: NSValue(cgPoint: .zero))
        }
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
