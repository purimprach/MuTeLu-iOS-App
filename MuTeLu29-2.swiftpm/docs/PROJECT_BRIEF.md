# MuTeLu - Project Brief
## สรุปภาพรวมโครงการ

### ภาพรวม (Overview)
**MuTeLu** (หมู่เทวดาลุ้น) เป็นแอปพลิเคชั่น iOS ที่พัฒนาด้วย SwiftUI สำหรับการท่องเที่ยวเชิงจิตวิญญาณและสังเกตการณ์สถานที่ศักดิ์สิทธิ์ในประเทศไทย แอปนี้ออกแบบมาเพื่อเป็นคู่มือดิจิตอลสำหรับผู้ที่ต้องการค้นหาวัดและสถานที่ศักดิ์สิทธิ์ พร้อมฟีเจอร์เสริมด้านการทำนายโชคลาง การแนะนำสถานที่ และเกมสังฆทาน

### เป้าหมายหลัก (Main Objectives)
1. **ค้นหาและแนะนำสถานที่ศักดิ์สิทธิ์** ตามตำแหน่งและความสนใจของผู้ใช้
2. **ให้ข้อมูลครบถ้วน** เกี่ยวกับวัด ศาลเจ้า และสถานที่ศักดิ์สิทธิ์
3. **สร้างประสบการณ์เชิงโต้ตอบ** ผ่านเกมและกิจกรรมต่างๆ
4. **ระบบสะสมบุญ** เพื่อจูงใจให้ผู้ใช้เข้าร่วมกิจกรรมทางศาสนา

### ระบบหลัก (Core Systems)

#### 1. ระบบผู้ใช้ (User Management System)
- **โครงสร้างข้อมูล**: `Member.swift`
  - ข้อมูลส่วนตัว (ชื่อ, เพศ, วันเกิด, เวลาเกิด)
  - ข้อมูลติดต่อ (อีเมล, เบอร์โทร, ที่อยู่)
  - ข้อมูลเสริม (ป้ายทะเบียนรถ, หมายเลขบ้าน)
  - คะแนนบุญ (Merit Points)
  - สถานะและสิทธิ์ (User/Admin)

#### 2. ระบบสถานที่ศักดิ์สิทธิ์ (Sacred Places System)
- **โครงสร้างข้อมูล**: `SacredPlace.swift`
  - ข้อมูลสองภาษา (ไทย/อังกฤษ)
  - ตำแหน่งพิกัด GPS
  - แท็กหมวดหมู่ (Tags)
  - คะแนนการรีวิว
  - รายละเอียดเสริม (บทสวด, เครื่องสักการะ, เวลาทำการ)

#### 3. ระบบแนะนำ (Recommendation Engine)
- **อัลกอริทึม**: Cosine Similarity
- **การทำงาน**: วิเคราะห์ความคล้ายคลึงระหว่างสถานที่จากแท็ก
- **ฟีเจอร์**: แนะนำสถานที่ตามความสนใจและประวัติการเยี่ยมชม

#### 4. ระบบตำแหน่ง (Location Services)
- **LocationManager.swift**: จัดการ GPS และ CoreLocation
- **RouteDistanceService.swift**: คำนวณระยะทางจริงผ่าน Apple Maps
- **ฟีเจอร์**: หาสถานที่ใกล้เคียง, ระยะทางแบบเส้นตรงและเส้นทางจริง

### ฟีเจอร์หลัก (Key Features)

#### 1. หน้าหลัก (Home Screen)
- **HomeView.swift**: แสดงสถานที่ใกล้เคียงและยอดนิยม
- **MainMenuView.swift**: เมนูหลักพร้อมการ์ดแนะนำ
- **Banner System**: แบนเนอร์วันสำคัญทางศาสนาและกิจกรรม

#### 2. ระบบทำนาย (Fortune Telling System)
- **PhoneFortuneView.swift**: ทำนายจากหมายเลขโทรศัพท์
- **ShirtColorView.swift**: แนะนำสีเสื้อประจำวัน
- **CarPlateView.swift**: วิเคราะห์ป้ายทะเบียนรถ
- **HouseNumberView.swift**: ทำนายจากหมายเลขบ้าน
- **TarotView.swift**: ระบบไพ่ทาโรต์
- **SeamSiView.swift**: เซียมซี

#### 3. ระบบสื่อการเรียนรู้ (Knowledge System)
- **MantraView.swift**: คาถามนต์และบทสวด
- **KnowledgeMenuView.swift**: เมนูความรู้ทางศาสนา
- **WishDetailView.swift**: วิธีการขอพรและคำอธิษฐาน

#### 4. ระบบเกม (Game System)
- **OfferingGameView.swift**: เกมสังฆทาน
- **OfferingGameViewModel.swift**: จัดการเกมโดยใช้ MVVM pattern
- **MeritPointsView.swift**: ระบบสะสมคะแนนบุญ

#### 5. ระบบ Check-in (Check-in System)
- **CheckInRecord.swift**: บันทึกการเยี่ยมชมสถานที่
- **HistoryView.swift**: ประวัติการเดินทาง

### สถาปัตยกรรม (Architecture)

#### Design Pattern
- **MVVM (Model-View-ViewModel)**: ใช้กับฟีเจอร์เกมและการจัดการข้อมูล
- **ObservableObject**: สำหรับ State Management
- **Environment Objects**: แชร์ข้อมูลระหว่าง Views

#### Navigation System
- **MuTeLuFlowManager.swift**: จัดการการเปลี่ยนหน้าจอแบบ centralized
- **Screen Enum**: กำหนดหน้าจอต่างๆ ในแอป
- **RootWrapperView.swift**: จุดเริ่มต้นของแอป

#### Data Management
- **JSON Loading**: โหลดข้อมูลสถานที่จากไฟล์ JSON
- **UserDefaults**: เก็บข้อมูลการ login และ preferences
- **In-Memory Storage**: ใช้ ObservableObject สำหรับข้อมูลชั่วคราว

### เทคโนโลยีที่ใช้ (Technologies Used)

#### Framework หลัก
- **SwiftUI**: UI Framework
- **CoreLocation**: ระบบตำแหน่ง
- **MapKit**: แสดงแผนที่และคำนวณเส้นทาง
- **Foundation**: ฟังก์ชันพื้นฐาน

#### Platform Requirements
- **iOS 18.1+**: เวอร์ชันขั้นต่ำ
- **iPhone และ iPad**: รองรับทั้งสองแพลตฟอร์ม
- **Swift 5.9**: เวอร์ชันภาษา

### โครงสร้างไฟล์ (File Structure)

```
MuTeLu29.swiftpm/
├── App Core/
│   ├── MuTeLuApp.swift           # Entry point
│   ├── ContentView.swift         # Root view
│   ├── AppView.swift             # Main app router
│   └── RootWrapperView.swift     # Wrapper view
├── Navigation/
│   └── MuTeLuFlowManager.swift   # Screen navigation
├── Models/
│   ├── Member.swift              # User model
│   ├── SacredPlace.swift         # Sacred place model
│   ├── CheckInRecord.swift       # Check-in model
│   └── OfferingItem.swift        # Game item model
├── Views/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── MainMenuView.swift
│   ├── Fortune/
│   │   ├── PhoneFortuneView.swift
│   │   ├── ShirtColorView.swift
│   │   └── TarotView.swift
│   ├── Sacred Places/
│   │   ├── SacredPlaceDetailView.swift
│   │   └── RecommendationView.swift
│   └── Profile/
│       ├── ProfileView.swift
│       └── EditProfileView.swift
├── Services/
│   ├── LocationManager.swift
│   ├── RouteDistanceService.swift
│   └── RecommendationEngine.swift
├── Resources/
│   ├── SacredPlacesDataNew.json
│   ├── LuckyColour.json
│   └── numberMeaning.json
└── Assets.xcassets/
    └── [รูปภาพต่างๆ]
```

### ฐานข้อมูลสถานที่ (Places Database)
แอปมีข้อมูลสถานที่ศักดิ์สิทธิ์หลากหลาย เช่น:
- **วัดพระแก้ว**: สถานที่ศักดิ์สิทธิ์ระดับชาติ
- **วัดโพธิ์**: วัดเก่าแก่มีพระพุทธรูปประจำ
- **วัดอรุณ**: วัดริมเจ้าพระยา
- **ศาลเจ้าต่างๆ**: ศาลเจ้าแขก, ศาลเจ้าจีน
- **พระบรมราชานุสาวรีย์**: อนุสรณ์สถานสำคัญ

### จุดเด่นของแอป (App Highlights)

#### 1. ระบบแนะนำอัจฉริยะ
- ใช้ Machine Learning เบื้องต้น (Cosine Similarity)
- วิเคราะห์ความชอบจากการเยี่ยมชม
- แนะนำสถานที่ที่เหมาะสมกับผู้ใช้

#### 2. การผสมผสานเทคโนโลยีกับศาสนา
- นำเทคโนโลยีมาช่วยในการเผยแพร่พุทธศาสนา
- รักษาความเป็นไทยในการออกแบบ UI/UX
- เนื้อหาสองภาษา (ไทย-อังกฤษ)

#### 3. Gamification
- ระบบคะแนนบุญเพื่อจูงใจ
- เกมสังฆทานเพื่อการเรียนรู้
- Check-in system สำหรับสร้าง engagement

### การพัฒนาในอนาคต (Future Development)

#### Phase 2
- **Social Features**: แชร์ประสบการณ์กับเพื่อน
- **Push Notifications**: แจ้งเตือนวันสำคัญ
- **Online Booking**: จองคิวพิธีกรรม

#### Phase 3
- **AR Features**: Augmented Reality สำหรับการท่องเที่ยว
- **Live Streaming**: ถ่ายทอดสดพิธีกรรม
- **E-commerce**: ร้านค้าเครื่องสักการะออนไลน์

### สรุป (Summary)
MuTeLu เป็นแอปพลิเคชั่นที่ผสมผสานเทคโนโลยีสมัยใหม่เข้ากับวัฒนธรรมและศาสนาไทย โดยมุ่งเน้นการสร้างประสบการณ์ที่ดีในการท่องเที่ยวเชิงจิตวิญญาณ พร้อมกับระบบแนะนำที่ฉลาดและฟีเจอร์เสริมที่หลากหลาย แอปนี้เหมาะสำหรับผู้ที่สนใจศาสนา วัฒนธรรม และการท่องเที่ยวในประเทศไทย

---
*Document Created: 2025-09-26*  
*Project Version: 1.0*  
*iOS Target: 18.1+*