import Foundation
import SwiftUI

// 1. enum MuTeLuScreen: กำหนดหน้าจอทั้งหมดในแอป
// ต้องอยู่นอก Class เพื่อให้ไฟล์อื่นมองเห็นได้
enum MuTeLuScreen {
    case home
    case login
    case registration
    case editProfile
    case recommenderForYou
    case recommendation
    case sacredDetail(place: SacredPlace)
    case phoneFortune
    case shirtColor
    case carPlate
    case houseNumber
    case tarot
    case mantra
    case seamSi
    case knowledge
    case wishDetail
    case adminLogin
    case admin
    case gameMenu
    case meritPoints
    case offeringGame
    case bookmarks
    case categorySearch
}

// 2. extension Hashable: ทำให้ enum สามารถใช้กับ NavigationPath ได้
extension MuTeLuScreen: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .sacredDetail(let place):
            hasher.combine("sacredDetail")
            hasher.combine(place.id)
        case .home: hasher.combine("home")
        case .login: hasher.combine("login")
        case .registration: hasher.combine("registration")
        case .editProfile: hasher.combine("editProfile")
        case .recommenderForYou: hasher.combine("recommenderForYou")
        case .recommendation: hasher.combine("recommendation")
        case .phoneFortune: hasher.combine("phoneFortune")
        case .shirtColor: hasher.combine("shirtColor")
        case .carPlate: hasher.combine("carPlate")
        case .houseNumber: hasher.combine("houseNumber")
        case .tarot: hasher.combine("tarot")
        case .mantra: hasher.combine("mantra")
        case .seamSi: hasher.combine("seamSi")
        case .knowledge: hasher.combine("knowledge")
        case .wishDetail: hasher.combine("wishDetail")
        case .adminLogin: hasher.combine("adminLogin")
        case .admin: hasher.combine("admin")
        case .gameMenu: hasher.combine("gameMenu")
        case .meritPoints: hasher.combine("meritPoints")
        case .offeringGame: hasher.combine("offeringGame")
        case .bookmarks: hasher.combine("bookmarks")
        case .categorySearch: hasher.combine("categorySearch")
        }
    }
}


// 3. class MuTeLuFlowManager: ตัวจัดการการนำทางหลัก
class MuTeLuFlowManager: ObservableObject {
    // ใช้ NavigationPath เพื่อเก็บประวัติการเดินทางทั้งหมด
    @Published var path = NavigationPath()
    
    // ใช้ควบคุม Tab ที่ถูกเลือกในหน้า HomeView
    // HomeView.HomeTab คือ enum ที่อยู่ในไฟล์ HomeView.swift
    @Published var selectedTab: HomeView.HomeTab = .home
    
    // จัดการสถานะการล็อกอิน
    @Published var isLoggedIn: Bool = false {
        didSet {
            if !isLoggedIn {
                // ถ้า logout ให้ล้างประวัติการเดินทางทั้งหมด
                path = NavigationPath()
            }
        }
    }
    
    // ข้อมูลผู้ใช้ (เหมือนเดิม)
    @Published var members: [Member] = []
    @Published var loggedInEmail: String = ""
}
