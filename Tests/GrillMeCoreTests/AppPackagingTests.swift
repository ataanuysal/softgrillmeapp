import Foundation
import ImageIO
import Testing

@Suite("App Store paketleme")
struct AppPackagingTests {
  @Test("AppIcon asseti ve Info.plist ikon adı dağıtım için yapılandırılmıştır")
  func configuresAppIconForDistribution() throws {
    let appIconDirectory =
      repositoryRoot
      .appendingPathComponent("GrillMe/App/Assets.xcassets/AppIcon.appiconset")
    let contentsURL = appIconDirectory.appendingPathComponent("Contents.json")
    let iconURL = appIconDirectory.appendingPathComponent("AppIcon-1024.png")

    #expect(FileManager.default.fileExists(atPath: contentsURL.path))
    #expect(FileManager.default.fileExists(atPath: iconURL.path))
    guard FileManager.default.fileExists(atPath: iconURL.path) else { return }

    let source = try #require(CGImageSourceCreateWithURL(iconURL as CFURL, nil))
    let properties = try #require(
      CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
    )
    #expect(properties[kCGImagePropertyPixelWidth] as? Int == 1024)
    #expect(properties[kCGImagePropertyPixelHeight] as? Int == 1024)

    let project = try String(
      contentsOf: repositoryRoot.appendingPathComponent("GrillMe.xcodeproj/project.pbxproj"),
      encoding: .utf8
    )
    #expect(project.contains("Assets.xcassets in Resources"))
    #expect(project.contains("ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;"))
    #expect(project.contains("INFOPLIST_KEY_CFBundleIconName = AppIcon;"))
  }

  private var repositoryRoot: URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
  }
}
