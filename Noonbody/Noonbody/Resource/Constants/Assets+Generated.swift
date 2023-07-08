// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Color {
    internal enum Background {
      internal static let `default` = ColorAsset(name: "Default")
      internal static let layer = ColorAsset(name: "Layer")
      internal static let neutral = ColorAsset(name: "Neutral")
    }
    internal static let borderLine = ColorAsset(name: "BorderLine")
    internal enum Common {
      internal static let black = ColorAsset(name: "Black")
      internal static let white = ColorAsset(name: "White")
    }
    internal enum Input {
      internal static let background = ColorAsset(name: "Background")
      internal static let border = ColorAsset(name: "Border")
      internal static let darkBorder = ColorAsset(name: "DarkBorder")
      internal static let lightBorder = ColorAsset(name: "LightBorder")
    }
    internal enum Primary {
      internal static let main = ColorAsset(name: "Main")
      internal static let text = ColorAsset(name: "Text")
    }
    internal static let red = ColorAsset(name: "Red")
    internal enum Switch {
      internal static let enabled = ColorAsset(name: "Enabled")
      internal static let focused = ColorAsset(name: "Focused")
    }
    internal enum Text {
      internal static let disabled = ColorAsset(name: "Disabled")
      internal static let primary = ColorAsset(name: "Primary")
      internal static let secondary = ColorAsset(name: "Secondary")
      internal static let tertirary = ColorAsset(name: "Tertirary")
    }
  }
  internal enum Image {
    internal static let add = ImageAsset(name: "Add")
    internal static let album = ImageAsset(name: "Album")
    internal static let arrowDown = ImageAsset(name: "ArrowDown")
    internal static let back02 = ImageAsset(name: "Back02")
    internal static let close = ImageAsset(name: "Close")
    internal static let create = ImageAsset(name: "Create")
    internal static let delGray = ImageAsset(name: "DelGray")
    internal static let empty = ImageAsset(name: "Empty")
    internal static let empty2 = ImageAsset(name: "Empty2")
    internal static let grid = ImageAsset(name: "Grid")
    internal static let list = ImageAsset(name: "List")
    internal static let listGradation = ImageAsset(name: "ListGradation")
    internal static let logo = ImageAsset(name: "Logo")
    internal static let logoShadow = ImageAsset(name: "Logo_shadow")
    internal static let lower = ImageAsset(name: "Lower")
    internal static let mUpper = ImageAsset(name: "M_Upper")
    internal static let mUpper2 = ImageAsset(name: "M_Upper2")
    internal static let mWhole = ImageAsset(name: "M_Whole")
    internal static let photo = ImageAsset(name: "Photo")
    internal static let pose = ImageAsset(name: "Pose")
    internal static let share = ImageAsset(name: "Share")
    internal static let shareGray = ImageAsset(name: "ShareGray")
    internal static let shareWhite = ImageAsset(name: "ShareWhite")
    internal static let upper = ImageAsset(name: "Upper")
    internal static let wLower = ImageAsset(name: "W_Lower")
    internal static let wUpper = ImageAsset(name: "W_Upper")
    internal static let wWhole = ImageAsset(name: "W_Whole")
    internal static let whole = ImageAsset(name: "Whole")
    internal static let back = ImageAsset(name: "back")
    internal static let backwardsBack = ImageAsset(name: "backwardsBack")
    internal static let check = ImageAsset(name: "check")
    internal static let checkCircle = ImageAsset(name: "check_circle")
    internal static let clear = ImageAsset(name: "clear")
    internal static let del = ImageAsset(name: "del")
    internal static let done = ImageAsset(name: "done")
    internal static let downBtn = ImageAsset(name: "downBtn")
    internal static let faceID = ImageAsset(name: "faceID")
    internal static let folderOpen = ImageAsset(name: "folder_open")
    internal static let gridIndicator = ImageAsset(name: "gridIndicator")
    internal static let manUpper2 = ImageAsset(name: "manUpper2")
    internal static let manLower01 = ImageAsset(name: "man_lower01")
    internal static let manUpper02 = ImageAsset(name: "man_upper02")
    internal static let manWhole = ImageAsset(name: "man_whole")
    internal static let manWhole01 = ImageAsset(name: "man_whole01")
    internal static let next = ImageAsset(name: "next")
    internal static let `none` = ImageAsset(name: "none")
    internal static let option = ImageAsset(name: "option")
    internal static let photoCamera = ImageAsset(name: "photo_camera")
    internal static let privacyThumbnail = ImageAsset(name: "privacyThumbnail")
    internal static let profileImg = ImageAsset(name: "profile_img")
    internal static let refresh = ImageAsset(name: "refresh")
    internal static let sample = ImageAsset(name: "sample")
    internal static let samplePose = ImageAsset(name: "samplePose")
    internal static let selectedClose = ImageAsset(name: "selectedClose")
    internal static let setting = ImageAsset(name: "setting")
    internal static let trash = ImageAsset(name: "trash")
    internal static let womanLower01 = ImageAsset(name: "woman_lower01")
    internal static let womanUpper02 = ImageAsset(name: "woman_upper02")
    internal static let womanWhole01 = ImageAsset(name: "woman_whole01")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal private(set) lazy var swiftUIColor: SwiftUI.Color = {
    SwiftUI.Color(asset: self)
  }()
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Color {
  init(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
