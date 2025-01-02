import Foundation

struct Question: Codable {
    let category: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    var allAnswers: [String] {
        (incorrectAnswers + [correctAnswer]).shuffled()
    }
}

private struct QuestionsWrapper: Codable {
    let questions: [Question]
} 