import Foundation

class QuizService {
    func fetchQuestions() async throws -> [Question] {
        // Hardcoded Manchester United questions
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