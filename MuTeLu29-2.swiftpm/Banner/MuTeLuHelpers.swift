import Foundation
import SwiftUI

struct DailyFortuneSet {
    let weekday: Int
    let icon: String
    let fortuneTH: String
    let fortuneEN: String
    let goodColor: String
    let goodColorEN: String
    let badColor: String
    let badColorEN: String
    let templeNameTH: String
    let templeNameEN: String
    let templeDescTH: String
    let templeDescEN: String
    let imageName: String
}

let dailyFortuneData: [DailyFortuneSet] = [
    DailyFortuneSet(weekday: 1, icon: "☀️",
                    fortuneTH: "วันนี้เหมาะกับการเริ่มต้นใหม่ 💡",
                    fortuneEN: "A great day to start something new 💡",
                    goodColor: "แดง", goodColorEN: "Red",
                    badColor: "ฟ้า/น้ำเงิน", badColorEN: "Light Blue / Blue",
                    templeNameTH: "วัดพระแก้ว", templeNameEN: "Wat Phra Kaew",
                    templeDescTH: "เหมาะกับวันอาทิตย์ เสริมบารมี",
                    templeDescEN: "Best for Sunday. Enhances prestige and honor.",
                    imageName: "wat_phra_kaew"),
    DailyFortuneSet(weekday: 2, icon: "🌕",
                    fortuneTH: "ดวงด้านความรักสดใส ❤️",
                    fortuneEN: "Love is in the air ❤️",
                    goodColor: "เหลือง", goodColorEN: "Yellow",
                    badColor: "แดง", badColorEN: "Red",
                    templeNameTH: "วัดอรุณ", templeNameEN: "Wat Arun",
                    templeDescTH: "เหมาะกับวันจันทร์ เสริมเสน่ห์",
                    templeDescEN: "Best for Monday. Increases charm and grace.",
                    imageName: "wat_arun"),
    DailyFortuneSet(weekday: 3, icon: "🔥",
                    fortuneTH: "ระวังอารมณ์ แต่โชคเรื่องเงิน 💸",
                    fortuneEN: "Watch your mood, but luck in money 💸",
                    goodColor: "ชมพู", goodColorEN: "Pink",
                    badColor: "เหลือง", badColorEN: "Yellow",
                    templeNameTH: "วัดโพธิ์", templeNameEN: "Wat Pho",
                    templeDescTH: "เหมาะกับวันอังคาร เพิ่มความมั่นคง",
                    templeDescEN: "Best for Tuesday. Brings stability.",
                    imageName: "wat_pho"),
    DailyFortuneSet(weekday: 4, icon: "🌳",
                    fortuneTH: "เหมาะเจรจา ติดต่อธุรกิจ 📞",
                    fortuneEN: "Perfect for communication and deals 📞",
                    goodColor: "เขียว", goodColorEN: "Green",
                    badColor: "ชมพู", badColorEN: "Pink",
                    templeNameTH: "วัดบวร", templeNameEN: "Wat Bowon",
                    templeDescTH: "เหมาะกับวันพุธ เสริมเมตตาและปัญญา",
                    templeDescEN: "Best for Wednesday. Enhances wisdom and kindness.",
                    imageName: "wat_bowon"),
    DailyFortuneSet(weekday: 5, icon: "📘",
                    fortuneTH: "เสริมพลังการเรียน การงาน 📚",
                    fortuneEN: "Good for learning and career boost 📚",
                    goodColor: "ส้ม/แสด", goodColorEN: "Orange",
                    badColor: "ม่วง", badColorEN: "Purple",
                    templeNameTH: "วัดสระเกศ", templeNameEN: "Wat Saket",
                    templeDescTH: "เหมาะกับวันพฤหัส เสริมการเรียนและโชคลาภ",
                    templeDescEN: "Best for Thursday. Great for education and luck.",
                    imageName: "wat_saket"),
    DailyFortuneSet(weekday: 6, icon: "🌈",
                    fortuneTH: "เสน่ห์แรง เงินเข้าไม่ขาดสาย 💖",
                    fortuneEN: "Magnetic charm and wealth ahead 💖",
                    goodColor: "ฟ้า/น้ำเงินอ่อน", goodColorEN: "Light Blue",
                    badColor: "ดำ", badColorEN: "Black",
                    templeNameTH: "วัดเทพธิดาราม", templeNameEN: "Wat Thepthidaram",
                    templeDescTH: "เหมาะกับวันศุกร์ เสริมความรักและเสน่ห์",
                    templeDescEN: "Best for Friday. Enhances love and attraction.",
                    imageName: "wat_thepthidaram"),
    DailyFortuneSet(weekday: 7, icon: "🌑",
                    fortuneTH: "เหมาะทำบุญ สงบจิตใจ 🧘‍♀️",
                    fortuneEN: "Ideal for meditation and merit 🧘‍♀️",
                    goodColor: "ม่วง/ดำ", goodColorEN: "Purple / Black",
                    badColor: "เขียว", badColorEN: "Green",
                    templeNameTH: "วัดอัปสรสวรรค์", templeNameEN: "Wat Apsornsawan",
                    templeDescTH: "เหมาะกับวันเสาร์ เสริมพลังและสติ",
                    templeDescEN: "Best for Saturday. Enhances mental strength.",
                    imageName: "wat_apsornsawan")
]

// MARK: - Helper functions

func getDailyFortuneSet(for member: Member?) -> DailyFortuneSet {
    let calendar = Calendar.current
    let weekday = calendar.component(.weekday, from: member?.birthdate ?? Date())
    return dailyFortuneData.first { $0.weekday == weekday } ?? dailyFortuneData[0]
}

func getDailyFortuneTH(for member: Member?) -> String {
    getDailyFortuneSet(for: member).fortuneTH
}

func getDailyFortuneEN(for member: Member?) -> String {
    getDailyFortuneSet(for: member).fortuneEN
}

func getFortuneInfo(for member: Member?) -> (goodColorTH: String, goodColorEN: String, badColorTH: String, badColorEN: String) {
    let set = getDailyFortuneSet(for: member)
    return (set.goodColor, set.goodColorEN, set.badColor, set.badColorEN)
}

func getRecommendedTemple(for member: Member?) -> (nameTH: String, nameEN: String, descTH: String, descEN: String, imageName: String) {
    let set = getDailyFortuneSet(for: member)
    return (set.templeNameTH, set.templeNameEN, set.templeDescTH, set.templeDescEN, set.imageName)
}
