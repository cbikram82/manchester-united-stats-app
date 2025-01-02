import SwiftUI

struct QuizView: View {
    @StateObject private var viewModel = QuizViewModel()
    @State private var showingResults = false
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()
                
                if viewModel.isLoading {
                    LoadingView()
                } else if let question = viewModel.currentQuestion {
                    QuestionContentView(
                        question: question,
                        viewModel: viewModel
                    )
                }
                
                if showingResults {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    
                    ResultView(
                        score: viewModel.score,
                        total: viewModel.questions.count
                    ) {
                        showingResults = false
                        viewModel.restart()
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .navigationTitle("United Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color(red: 0.8, green: 0, blue: 0), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .task {
                await viewModel.loadQuestions()
            }
            .animation(.easeInOut, value: showingResults)
        }
        .onChange(of: viewModel.showingScore) { _, newValue in
            if newValue {
                showingResults = true
            }
        }
    }
}

// Background View
private struct BackgroundView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.8, green: 0, blue: 0),
                Color(red: 0.6, green: 0, blue: 0),
                Color.black
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// Loading View
private struct LoadingView: View {
    var body: some View {
        ProgressView()
            .tint(.white)
    }
}

// Question Content View
private struct QuestionContentView: View {
    let question: Question
    @ObservedObject var viewModel: QuizViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                LogoView()
                QuestionHeaderView(question: question)
                AnswersView(question: question, viewModel: viewModel)
                
                Group {
                    if viewModel.showingAnswerFeedback {
                        FeedbackView(
                            isCorrect: viewModel.isCorrectAnswer,
                            correctAnswer: question.correctAnswer
                        )
                    }
                }
                .animation(.spring(), value: viewModel.showingAnswerFeedback)
                
                Spacer()
                
                QuizProgressView(viewModel: viewModel)
            }
            .padding()
        }
    }
}

// Logo View
private struct LogoView: View {
    var body: some View {
        Image("united_logo")
            .resizable()
            .scaledToFit()
            .frame(height: 60)
            .padding(.top)
    }
}

// Question Header View
private struct QuestionHeaderView: View {
    let question: Question
    
    var body: some View {
        VStack(spacing: 10) {
            Text(question.category)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.3))
                .cornerRadius(8)
            
            Text(question.question)
                .font(.title3)
                .bold()
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.2))
                .cornerRadius(15)
        }
    }
}

// Answers View
private struct AnswersView: View {
    let question: Question
    @ObservedObject var viewModel: QuizViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(question.allAnswers, id: \.self) { answer in
                AnswerButton(
                    answer: answer,
                    isSelected: viewModel.showingAnswerFeedback && viewModel.selectedAnswer == answer,
                    isCorrect: answer == question.correctAnswer,
                    showingFeedback: viewModel.showingAnswerFeedback
                ) {
                    viewModel.checkAnswer(answer)
                }
            }
        }
        .padding(.vertical)
    }
}

// Quiz Progress View
private struct QuizProgressView: View {
    @ObservedObject var viewModel: QuizViewModel
    
    var body: some View {
        HStack {
            Text("Question \(viewModel.currentQuestionIndex + 1)/\(viewModel.questions.count)")
                .font(.callout)
                .foregroundColor(.white)
            
            Spacer()
            
            Text("Score: \(viewModel.score)")
                .font(.callout)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.3))
                .cornerRadius(8)
        }
        .padding(.horizontal)
    }
}

struct AnswerButton: View {
    let answer: String
    let isSelected: Bool
    let isCorrect: Bool
    let showingFeedback: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(answer)
                .font(.body)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(borderColor, lineWidth: 2)
                        )
                )
                .shadow(color: shadowColor, radius: isSelected ? 5 : 0)
        }
        .disabled(showingFeedback)
    }
    
    private var backgroundColor: Color {
        if !showingFeedback {
            return Color.black.opacity(0.3)
        }
        if isSelected {
            return isCorrect ? Color.green.opacity(0.3) : Color.red.opacity(0.3)
        }
        if isCorrect && showingFeedback {
            return Color.green.opacity(0.3)
        }
        return Color.black.opacity(0.3)
    }
    
    private var borderColor: Color {
        if showingFeedback {
            if isSelected {
                return isCorrect ? .green : .red
            }
            if isCorrect {
                return .green
            }
        }
        return Color.white.opacity(0.2)
    }
    
    private var shadowColor: Color {
        if showingFeedback {
            if isSelected {
                return isCorrect ? .green.opacity(0.5) : .red.opacity(0.5)
            }
            if isCorrect {
                return .green.opacity(0.5)
            }
        }
        return .clear
    }
}

struct FeedbackView: View {
    let isCorrect: Bool
    let correctAnswer: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(isCorrect ? .green : .red)
            
            Text(isCorrect ? "Correct! 🎉" : "Wrong!")
                .font(.headline)
                .foregroundColor(isCorrect ? .green : .red)
            
            if !isCorrect {
                Text("Correct answer: \(correctAnswer)")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color.white.opacity(0.95))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}