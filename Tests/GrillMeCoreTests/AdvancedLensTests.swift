import Testing

@testable import GrillMeCore

@Suite("İleri Kod Röntgeni lensleri")
struct AdvancedLensTests {
  @Test("Çağrı lensi fonksiyon çerçevelerini ve yerel değerleri taşır")
  func exposesCallStackFrames() {
    let step = TraceStep(
      lineNumber: 2,
      explanation: "Fonksiyon gövdesi çalışır.",
      memory: ["sonuc": "8"],
      output: nil,
      callStack: [
        CallFrame(functionName: "program", locals: [:]),
        CallFrame(functionName: "ikiKat", locals: ["sayi": "4"]),
      ]
    )
    let lesson = lesson(trace: [step])

    #expect(lesson.availableLenses.contains(.call))
    #expect(step.callStack.map(\.functionName) == ["program", "ikiKat"])
    #expect(step.callStack.last?.locals["sayi"] == "4")
  }

  @Test("Mimari lens instance ve sahiplik ilişkilerini görünür kılar")
  func exposesArchitectureRelationships() {
    let snapshot = ArchitectureSnapshot(
      entities: [
        ArchitectureEntity(id: "class-Hesap", label: "Hesap", kind: .class),
        ArchitectureEntity(id: "hesap-1", label: "hesap", kind: .instance),
        ArchitectureEntity(id: "bakiye", label: "bakiye = 20", kind: .value),
      ],
      relationships: [
        ArchitectureRelationship(
          sourceID: "hesap-1",
          targetID: "class-Hesap",
          label: "örneğidir"
        ),
        ArchitectureRelationship(
          sourceID: "hesap-1",
          targetID: "bakiye",
          label: "sahiptir"
        ),
      ]
    )
    let step = TraceStep(
      lineNumber: 4,
      explanation: "Bir instance oluşur.",
      memory: ["bakiye": "20"],
      output: nil,
      architecture: snapshot
    )
    let lesson = lesson(trace: [step])

    #expect(lesson.availableLenses.contains(.architecture))
    #expect(snapshot.entities.count == 3)
    #expect(snapshot.relationships.map(\.label) == ["örneğidir", "sahiptir"])
  }

  @Test("Ders desteklediği lensleri içerikten otomatik çıkarır")
  func derivesAvailableLenses() {
    let challenge = DebugChallenge(
      kind: .logic,
      prompt: "Yanlış sonucu üreten satırı bul.",
      code: [
        CodeLine(number: 1, text: "var toplam = 0"),
        CodeLine(number: 2, text: "toplam = toplam - 3"),
      ],
      correctLineNumber: 2,
      expected: "3",
      actual: "-3",
      explanation: "Toplama yerine çıkarma yapılmış."
    )
    let lesson = XRayLesson(
      title: "Hata avı",
      question: "Sorun nerede?",
      code: challenge.code,
      choices: ["-3"],
      correctAnswer: "-3",
      trace: [
        TraceStep(
          lineNumber: 2,
          explanation: "Değer azalır.",
          memory: ["toplam": "-3"],
          output: "-3"
        )
      ],
      debugChallenge: challenge
    )

    #expect(lesson.availableLenses == [.flow, .memory, .output, .error])
  }

  private func lesson(trace: [TraceStep]) -> XRayLesson {
    XRayLesson(
      title: "Lens",
      question: "Ne olur?",
      code: [CodeLine(number: 2, text: "print(8)")],
      choices: ["8"],
      correctAnswer: "8",
      trace: trace
    )
  }
}
