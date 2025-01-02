import Foundation
import SwiftUI

private struct QuestionsWrapper: Codable {
    let questions: [Question]
}

class QuizService {
    private let openAIKey = "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"  // Replace with your key
    private let openAIEndpoint = "https://api.openai.com/v1/chat/completions"
    
    func fetchQuestions() async throws -> [Question] {
        let prompt = """
        Generate 10 unique and diverse multiple choice questions about Manchester United Football Club.
        Include questions from different eras and categories:
        - Classic history (1878-1990)
        - Modern history (1991-present)
        - Players and managers
        - Trophies and achievements
        - Records and statistics
        - Memorable matches
        - Stadium and facilities
        - Club culture and traditions
        
        Format each question as JSON with the following structure:
        {
            "questions": [
                {
                    "category": "Manchester United [Category]",
                    "question": "[Question Text]",
                    "correctAnswer": "[Correct Answer]",
                    "incorrectAnswers": ["[Wrong Answer 1]", "[Wrong Answer 2]", "[Wrong Answer 3]"]
                }
            ]
        }
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a football quiz expert specializing in Manchester United history. Generate unique questions each time."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.9,
            "max_tokens": 2000
        ]
        
        var request = URLRequest(url: URL(string: openAIEndpoint)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Debug response
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code: \(httpResponse.statusCode)")
        }
        
        do {
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            guard let content = openAIResponse.choices.first?.message.content else {
                print("No content in response")
                return getFallbackQuestions()
            }
            
            // Clean up the content string
            let cleanedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard let jsonData = cleanedContent.data(using: .utf8) else {
                print("Could not convert content to data")
                return getFallbackQuestions()
            }
            
            do {
                // Use the QuestionsWrapper defined at the top level
                let wrapper = try JSONDecoder().decode(QuestionsWrapper.self, from: jsonData)
                return wrapper.questions
            } catch {
                print("Error decoding questions: \(error)")
                
                // Try manual parsing as fallback
                if let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                   let questionsArray = json["questions"] as? [[String: Any]] {
                    
                    return try questionsArray.map { dict in
                        guard let category = dict["category"] as? String,
                              let question = dict["question"] as? String,
                              let correctAnswer = dict["correctAnswer"] as? String,
                              let incorrectAnswers = dict["incorrectAnswers"] as? [String] else {
                            throw NetworkError.decodingError
                        }
                        
                        return Question(
                            category: category,
                            question: question,
                            correctAnswer: correctAnswer,
                            incorrectAnswers: incorrectAnswers
                        )
                    }
                }
                
                return getFallbackQuestions()
            }
        } catch {
            print("OpenAI Response decoding error: \(error)")
            return getFallbackQuestions()
        }
    }
}

// Updated OpenAI response models
struct OpenAIResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage
    let systemFingerprint: String?
    
    struct Choice: Codable {
        let index: Int
        let message: Message
        let logprobs: JSONValue?
        let finishReason: String
        
        enum CodingKeys: String, CodingKey {
            case index
            case message
            case logprobs
            case finishReason = "finish_reason"
        }
    }
    
    struct Message: Codable {
        let role: String
        let content: String
        let refusal: String?
    }
    
    struct Usage: Codable {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int
        
        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case created
        case model
        case choices
        case usage
        case systemFingerprint = "system_fingerprint"
    }
}

// Add this enum to handle null values
enum JSONValue: Codable {
    case string(String)
    case null
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else {
            let string = try container.decode(String.self)
            self = .string(string)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let string):
            try container.encode(string)
        case .null:
            try container.encodeNil()
        }
    }
}

// Add error handling and retry logic
extension QuizService {
    func fetchQuestionsWithRetry(maxAttempts: Int = 3) async throws -> [Question] {
        var lastError: Error?
        
        for attempt in 1...maxAttempts {
            do {
                return try await fetchQuestions()
            } catch {
                lastError = error
                print("Attempt \(attempt) failed: \(error.localizedDescription)")
                try await Task.sleep(nanoseconds: UInt64(1_000_000_000 * attempt))
            }
        }
        
        throw lastError ?? NetworkError.invalidResponse
    }
    
    // Fallback questions in case API fails
    func getFallbackQuestions() -> [Question] {
        return [
            Question(
                category: "Manchester United History",
                question: "Who is known as 'The King of Old Trafford'?",
                correctAnswer: "Eric Cantona",
                incorrectAnswers: ["Wayne Rooney", "George Best", "David Beckham"]
            ),
            Question(
                category: "Manchester United History",
                question: "In which year did Manchester United win their first UEFA Champions League (European Cup)?",
                correctAnswer: "1968",
                incorrectAnswers: ["1999", "2008", "1958"]
            ),
            Question(
                category: "Manchester United Players",
                question: "Who holds the record for most appearances for Manchester United?",
                correctAnswer: "Ryan Giggs",
                incorrectAnswers: ["Bobby Charlton", "Paul Scholes", "Gary Neville"]
            ),
            Question(
                category: "Manchester United Trophies",
                question: "How many Premier League titles have Manchester United won?",
                correctAnswer: "20",
                incorrectAnswers: ["18", "19", "21"]
            ),
            Question(
                category: "Manchester United History",
                question: "Who was Manchester United's manager during the historic treble-winning season of 1998-99?",
                correctAnswer: "Sir Alex Ferguson",
                incorrectAnswers: ["Matt Busby", "Ron Atkinson", "Tommy Docherty"]
            ),
            Question(
                category: "Manchester United Players",
                question: "Which player scored the winning goal in the 1999 Champions League final?",
                correctAnswer: "Ole Gunnar Solskjaer",
                incorrectAnswers: ["Teddy Sheringham", "David Beckham", "Andy Cole"]
            ),
            Question(
                category: "Manchester United Stadium",
                question: "What is the current capacity of Old Trafford?",
                correctAnswer: "74,140",
                incorrectAnswers: ["69,000", "82,000", "71,000"]
            ),
            Question(
                category: "Manchester United History",
                question: "What year was Manchester United founded?",
                correctAnswer: "1878",
                incorrectAnswers: ["1902", "1888", "1892"]
            ),
            Question(
                category: "Manchester United Players",
                question: "Who is Manchester United's all-time top scorer?",
                correctAnswer: "Wayne Rooney",
                incorrectAnswers: ["Bobby Charlton", "Denis Law", "George Best"]
            ),
            Question(
                category: "Manchester United History",
                question: "What was Manchester United originally called when first formed?",
                correctAnswer: "Newton Heath LYR",
                incorrectAnswers: ["Manchester FC", "United FC", "Red Devils FC"]
            )
        ]
    }
}
