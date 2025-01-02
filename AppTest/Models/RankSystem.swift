import Foundation

struct RankSystem {
    static func getRank(score: Int, total: Int) -> (title: String, message: String) {
        let percentage = (Double(score) / Double(total)) * 100
        
        switch percentage {
        case 100:
            return (
                "Sir Alex Ferguson Level! 🏆",
                "Absolutely brilliant! You're a true Red Devils encyclopedia!"
            )
        case 90..<100:
            return (
                "Club Legend Status 🌟",
                "Outstanding knowledge! You could give the club tour guides a run for their money!"
            )
        case 80..<90:
            return (
                "First Team Regular 👊",
                "Great performance! You really know your United history!"
            )
        case 70..<80:
            return (
                "Squad Player 👍",
                "Solid showing! You've got good United knowledge!"
            )
        case 60..<70:
            return (
                "Youth Academy Graduate 🎓",
                "Not bad! Keep studying United's rich history!"
            )
        case 50..<60:
            return (
                "Season Ticket Holder 🎟",
                "You're getting there! Time to brush up on some United facts!"
            )
        case 30..<50:
            return (
                "Match Day Fan 📺",
                "Room for improvement! Try watching more United classics!"
            )
        case 20..<30:
            return (
                "Part-Time Supporter 😅",
                "You might want to spend more time at Old Trafford!"
            )
        case 10..<20:
            return (
                "City Fan in Disguise? 🤔",
                "Are you sure you're not from the blue side of Manchester?"
            )
        default:
            return (
                "Lost Tourist 😳",
                "Did you accidentally wander into Old Trafford?"
            )
        }
    }
} 