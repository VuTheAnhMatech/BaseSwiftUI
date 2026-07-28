//
//  Created by Vu The Anh on 2/4/26.
//

import Foundation

protocol BusinessResponseValidatable {
    var isBusinessSuccess: Bool { get }
    var businessCode: Int? { get }
    var businessMessage: String? { get }
}

extension BaseResponse: BusinessResponseValidatable {
    var isBusinessSuccess: Bool { isSuccess }
    var businessCode: Int? { code }
    var businessMessage: String? { message }
}

extension BaseSingleResponse: BusinessResponseValidatable {
    var isBusinessSuccess: Bool { isSuccess }
    var businessCode: Int? { code }
    var businessMessage: String? { message }
}
