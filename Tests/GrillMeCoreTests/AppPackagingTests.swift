import Foundation
import ImageIO
import Testing

@Suite("App Store paketleme")
struct AppPackagingTests {
  @Test("Depoda yalnızca aktif GrillMe uygulama projesi bulunur")
  func containsOnlyActiveApplicationProject() throws {
    let enumerator = try #require(
      FileManager.default.enumerator(
        at: repositoryRoot,
        includingPropertiesForKeys: nil,
        options: [.skipsHiddenFiles]
      )
    )
    var projectPaths: [String] = []

    for case let url as URL in enumerator where url.pathExtension == "xcodeproj" {
      projectPaths.append(url.path.replacingOccurrences(of: repositoryRoot.path + "/", with: ""))
      enumerator.skipDescendants()
    }

    #expect(projectPaths.sorted() == ["GrillMe.xcodeproj"])
  }

  @Test("Ders deneyimi tek durum makinesi kullanır")
  func usesSingleLessonStateMachine() throws {
    let sourcePaths = [
      "GrillMe/Core/GrillMeCore.swift",
      "GrillMe/Core/LessonRun.swift",
    ]
    let sources = try sourcePaths.map {
      try String(
        contentsOf: repositoryRoot.appendingPathComponent($0),
        encoding: .utf8
      )
    }

    #expect(sources.allSatisfy { !$0.contains("XRaySession") })
  }

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
