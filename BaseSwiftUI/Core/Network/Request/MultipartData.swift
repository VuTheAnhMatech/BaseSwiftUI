//
//  Created by Vu The Anh on 2/4/26.
//

import Foundation

struct MultipartDataExt {
    let data: Data
    let name: String
    let fileName: String
    let mimeType: String

    init(data: Data, name: String, fileName: String, mimeType: String) {
        self.data = data
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }
}
