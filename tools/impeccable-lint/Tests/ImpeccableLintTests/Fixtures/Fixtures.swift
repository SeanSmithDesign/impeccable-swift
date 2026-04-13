import Foundation

/// Short in-memory Swift source fixtures used by rule tests. Keeping them as
/// string constants avoids resource-bundle packaging in Swift Package Manager
/// tests while staying readable.
enum Fixtures {
    // MARK: - AccessibilityLabelRule

    static let a11yButtonIconNoLabel = #"""
    import SwiftUI
    struct V: View {
        var body: some View {
            Button { } label: {
                Image(systemName: "gear")
            }
        }
    }
    """#

    static let a11yButtonIconWithLabel = #"""
    import SwiftUI
    struct V: View {
        var body: some View {
            Button { } label: {
                Image(systemName: "gear")
            }
            .accessibilityLabel("Settings")
        }
    }
    """#

    static let a11yStandaloneIcon = #"""
    import SwiftUI
    struct V: View {
        var body: some View {
            Image(systemName: "star")
        }
    }
    """#

    static let a11yLabelInit = #"""
    import SwiftUI
    struct V: View {
        var body: some View {
            Label("Star", systemImage: "star")
        }
    }
    """#

    static let a11yDecorativeImage = #"""
    import SwiftUI
    struct V: View {
        var body: some View {
            Image(decorative: "star")
        }
    }
    """#

    static let a11yTapGestureNoLabel = #"""
    import SwiftUI
    struct V: View {
        var body: some View {
            Rectangle()
                .onTapGesture { }
        }
    }
    """#

    // MARK: - MultilineFrameOnTextRule

    static let frameOnTextSameLine = #"""
    import SwiftUI
    struct V: View {
        var body: some View {
            Text("hi").frame(width: 100, height: 40)
        }
    }
    """#

    static let frameOnTextMultiline = #"""
    import SwiftUI
    struct V: View {
        var body: some View {
            Text("hi")
                .frame(height: 40)
        }
    }
    """#

    static let frameOnTextMaxWidth = #"""
    import SwiftUI
    struct V: View {
        var body: some View {
            Text("hi").frame(maxWidth: .infinity)
        }
    }
    """#

    static let frameOnImage = #"""
    import SwiftUI
    struct V: View {
        var body: some View {
            Image(systemName: "star").frame(width: 20, height: 20)
        }
    }
    """#

    // MARK: - HardcodedFontInChainRule

    static let hardcodedFontSameLine = #"""
    import SwiftUI
    struct V: View {
        var body: some View {
            Text("hi").font(.system(size: 15))
        }
    }
    """#

    static let hardcodedFontMultiline = #"""
    import SwiftUI
    struct V: View {
        var body: some View {
            Text("hi")
                .font(.system(size: 15))
        }
    }
    """#

    static let semanticFont = #"""
    import SwiftUI
    struct V: View {
        var body: some View {
            Text("hi").font(.body)
        }
    }
    """#

    static let customFontWithRelativeTo = #"""
    import SwiftUI
    struct V: View {
        var body: some View {
            Text("hi").font(.custom("SF Mono", size: 14, relativeTo: .body))
        }
    }
    """#

    // MARK: - ContinuousCornerRule

    static let roundedRectNoStyle = #"""
    import SwiftUI
    struct V: View {
        var body: some View {
            RoundedRectangle(cornerRadius: 12)
        }
    }
    """#

    static let roundedRectContinuous = #"""
    import SwiftUI
    struct V: View {
        var body: some View {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
        }
    }
    """#

    static let cornerRadiusModifier = #"""
    import SwiftUI
    struct V: View {
        var body: some View {
            Rectangle().cornerRadius(12)
        }
    }
    """#

    static let clipShapeContinuous = #"""
    import SwiftUI
    struct V: View {
        var body: some View {
            Rectangle().clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
    """#
}
