//
//  User.swift
//  StudyOn
//
//  Created by Minseok Chey on 6/11/24.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var password: String
    var favoriteLocations: [String]
    
    init(id: String, email: String, password: String, favoriteLocations: [String] = []) {
        self.id = id
        self.email = email
        self.password = password
        self.favoriteLocations = favoriteLocations
    }
}

