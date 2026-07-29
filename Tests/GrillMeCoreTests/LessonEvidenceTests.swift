import Testing

@testable import GrillMeCore

@Suite("Ders tamamlama kanıtı")
struct LessonEvidenceTests {
  @Test("Capstone bütün görevler yanıtlanmadan tamamlanamaz")
  func requiresEveryCapstoneTask() {
    let lesson = LessonCatalog.standard.lessons.first { $0.id == "capstone" }!
    let evidence = LessonEvidence(
      quizAnswer: lesson.transferChallenge?.correctAnswer,
      practiceAnswers: [:],
      assessmentResponses: [:],
      debugCompleted: true
    )

    let evaluation = evidence.evaluate(for: lesson)

    #expect(!evaluation.isReadyToComplete)
    #expect(evaluation.missingRequirements.contains(.practice))
    #expect(evaluation.missingRequirements.contains(.assessment))
  }

  @Test("Bütün kanıtlar tamamlandığında ayrı puanlar üretir")
  func calculatesIndependentScores() {
    let lesson = LessonCatalog.standard.lessons.first { $0.id == "capstone" }!
    let practiceAnswers = Dictionary(
      uniqueKeysWithValues: lesson.practiceChallenges.enumerated().map {
        ($0.offset, $0.element.correctAnswer)
      }
    )
    let assessmentResponses = Dictionary(
      uniqueKeysWithValues: lesson.assessmentTasks.map {
        ($0.kind, $0.rubric.modelAnswer)
      }
    )
    let evidence = LessonEvidence(
      quizAnswer: lesson.transferChallenge?.correctAnswer,
      practiceAnswers: practiceAnswers,
      assessmentResponses: assessmentResponses,
      debugCompleted: true
    )

    let evaluation = evidence.evaluate(for: lesson)

    #expect(evaluation.isReadyToComplete)
    #expect(evaluation.quizCorrect == true)
    #expect(evaluation.practiceAccuracy == 1)
    #expect(evaluation.assessmentScore == 1)
    #expect(evaluation.missingRequirements.isEmpty)
  }
}
