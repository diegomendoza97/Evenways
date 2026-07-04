import SwiftUI

enum AppTheme {
    // MARK: - Colors
    static let background = Color(hex: "0F0F1A")
    static let cardBackground = Color(hex: "1A1A2E")
    static let cardBackgroundElevated = Color(hex: "232340")
    static let primary = Color(hex: "4F46E5")
    static let secondary = Color(hex: "7C3AED")
    static let tertiary = Color(hex: "A54100")
    static let neutral = Color(hex: "777681")
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "9CA3AF")
    static let inputBackground = Color(hex: "2A2A45")
    static let border = Color(hex: "2E2E4A")
    static let destructive = Color(hex: "EF4444")
}

extension String {
    /// Parses a user-entered number using the current locale, accepting both
    /// "." and "," as the decimal separator. Falls back to a plain parse so a
    /// value typed with the "wrong" separator still works.
    var localeAwareDouble: Double? {
        let trimmed = trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        if let number = formatter.number(from: trimmed) {
            return number.doubleValue
        }

        let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Reusable Components

struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppTheme.primary)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

struct PrimaryNavigationLink<Destination: View>: View {
    let title: String
    let icon: String?
    let destination: Destination

    init(_ title: String, icon: String? = nil, @ViewBuilder destination: () -> Destination) {
        self.title = title
        self.icon = icon
        self.destination = destination()
    }

    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.semibold)
                Image(systemName: "arrow.right")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppTheme.primary)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

struct ThemedTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .never

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.neutral)
                .tracking(0.5)
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(AppTheme.neutral)
                }
                TextField("", text: $text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autocapitalization)
                    .foregroundStyle(AppTheme.textPrimary)
            }
            .padding(12)
            .background(AppTheme.inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    let badge: String?

    init(_ title: String, icon: String, badge: String? = nil) {
        self.title = title
        self.icon = icon
        self.badge = badge
    }

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(AppTheme.primary)
                .font(.title3)
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.textPrimary)
            Spacer()
            if let badge {
                Text(badge)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.primary.opacity(0.2))
                    .foregroundStyle(AppTheme.primary)
                    .clipShape(Capsule())
            }
        }
    }
}

struct PersonInitialAvatar: View {
    let name: String
    let size: CGFloat

    private var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    private var color: Color {
        let colors: [Color] = [
            AppTheme.primary,
            AppTheme.secondary,
            Color(hex: "059669"),
            AppTheme.tertiary,
            Color(hex: "DC2626"),
            Color(hex: "0891B2"),
        ]
        let hash = abs(name.hashValue)
        return colors[hash % colors.count]
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: size, height: size)
            Text(initials)
                .font(.system(size: size * 0.36, weight: .semibold))
                .foregroundStyle(.white)
        }
    }
}
