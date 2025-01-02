import Foundation

@MainActor
class QuizViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentQuestionIndex = 0
    @Published var score = 0
    @Published var isLoading = false
    @Published var showingScore = false
    @Published var showingAnswerFeedback = false
    @Published var isCorrectAnswer = false
    @Published var selectedAnswer = ""
    
    private let quizService = QuizService()
    
    var currentQuestion: Question? {
        guard questions.indices.contains(currentQuestionIndex) else { return nil }
        return questions[currentQuestionIndex]
    }
    
    func loadQuestions() async {
        isLoading = true
        do {
            questions = try await quizService.fetchQuestionsWithRetry()
        } catch {
            print("Error loading questions: \(error)")
            questions = quizService.getFallbackQuestions()
        }
        isLoading = false
    }
    
    func checkAnswer(_ answer: String) {
        selectedAnswer = answer
        isCorrectAnswer = answer == currentQuestion?.correctAnswer
        showingAnswerFeedback = true
        
        if isCorrectAnswer {
            score += 1
        }
        
        // Wait 2 seconds before moving to next question
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            self.showingAnswerFeedback = false
            
            if self.currentQuestionIndex + 1 < self.questions.count {
                self.currentQuestionIndex += 1
            } else {
                self.showingScore = true
            }
        }
    }
    
    func restart() {
        currentQuestionIndex = 0
        score = 0
        showingScore = false
        showingAnswerFeedback = false
        selectedAnswer = ""
        Task {
            await loadQuestions()
        }
    }
}
