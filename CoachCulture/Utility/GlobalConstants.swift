// swiftlint:disable identifier_name

import Foundation
import UIKit

let formatter = NumberFormatter()
var DEFAULTS = UserDefaults.standard
let APPDELEGATE = UIApplication.shared.delegate as! AppDelegate

var isDevelopmentMode = true

// MARK: - API URL

struct DEFAULTS_KEY {
    static let FCM_TOKEN = "device_token"
    static let AUTH_TOKEN = "Authorization"
    static let USER_DATA = "LoginUserData"
    static let USER_ID = "UserId"
}

struct API {
    static let BASE_URL                      = "http://52.73.206.37/"
    
    static let REGISTER_USER                 = BASE_URL + "api/auth/register"
    static let LOGIN                         = BASE_URL + "api/auth/login"
    static let VERIFY_USER                         = BASE_URL + "api/auth/verify-user"
    static let CHECK_EMAIL                         = BASE_URL + "api/check-email"
    static let CHECK_PHONE                         = BASE_URL + "api/check-phoneno"
    static let RESEND_OTP                         = BASE_URL + "api/resend-OTP"
    static let VERIFY_OTP                         = BASE_URL + "api/auth/verify-otp"
    static let RESET_PASSWORD                         = BASE_URL + "api/reset-password"
    static let GET_UPCOMMING_LIVE_CLASS_LIST                         = BASE_URL + "api/coach-class/get-upcoming-live-class-list"
    static let GET_POPULAR_CLASS_LIST                         = BASE_URL + "api/coach-class/get-popular-class-list"
    
    static let GET_POPULAR_TRAINER_LIST                         = BASE_URL + "api/coach/get-popular-trainer-list"
    static let GET_PROFILE                         = BASE_URL + "api/auth/profile"
    static let UPLOAD_USER_IMAGE                         = BASE_URL + "api/auth/upload-user-image"
    static let NATIONALITY_LIST                         = BASE_URL + "api/nationality-list"
    static let REGISTER_COACH                         = BASE_URL + "api/auth/register-coach"
    static let EDIT_PROFILE                         = BASE_URL + "api/auth/edit-profile"
    static let EDIT_COACH_PROFILE                         = BASE_URL + "api/auth/edit-coach-profile"
    static let CLASS_TYPE_LIST                         = BASE_URL + "api/class-type-list"
    static let CLASS_DIFFICULTY_LIST                         = BASE_URL + "api/class-difficulty-list"
    static let MUSCLE_GROUP_LIST                         = BASE_URL + "api/muscle-group-list"
    static let EQUIPMENT_LIST                         = BASE_URL + "api/equipment-list"
    static let UPLOAD_VIDEO_THUMBNAIL                         = BASE_URL + "api/coach-class/upload-image-video"
    static let CREATE_COACH_CLASS                         = BASE_URL + "api/coach-class/create"
    static let EDIT_COACH_CLASS                         = BASE_URL + "api/coach-class/edit"

    static let MEAL_TYPE_LIST                         = BASE_URL + "api/meal-type-list"
    static let DIETARY_RES_LIST                         = BASE_URL + "api/dietary-restriction-list"
    static let UPLOAD_IMAGE_RECIPE                         = BASE_URL + "api/recipe/upload-image"
    static let CREATE_RECIPE                         = BASE_URL + "api/recipe/create"
    static let EDIT_RECIPE                         = BASE_URL + "api/recipe/edit"
    static let RECIPE_DETAILS                         = BASE_URL + "api/recipe/details"
    static let DELETE_USER_IMAGE                         = BASE_URL + "api/auth/delete-user-image"
    static let ADD_REMOVE_BOOKMARK                         = BASE_URL + "api/recipe/add-remove-bookmark"
    static let COACH_CLASS_DETAILS                         = BASE_URL + "api/coach-class/details"
    static let RECIPE_RATING                         = BASE_URL + "api/recipe/create-rating"
    static let COACH_CLASS_RATING                         = BASE_URL + "api/coach-class/create-rating"
    static let COACH_CLASS_DELETE                         = BASE_URL + "api/coach-class/delete/"
    static let COACH_CLASS_BOOKMARK                         = BASE_URL + "api/coach-class/add-remove-bookmark"
    static let COACH_ALL_SEARCH_LIST                         = BASE_URL + "api/coach/get-coach-search-list"
    static let COACH_FOLLOWING_SEARCH_LIST                         = BASE_URL + "api/coach/get-following-search-list"
    static let GET_POPULAR_RECIPE_LIST                         = BASE_URL + "api/recipe/get-popular-recipe-list"
    static let GET_YOUR_COACH_RECIPE_LIST                         = BASE_URL + "api/recipe/get-your-coach-recipe-list"
    static let GET_ALL_COACH_RECIPE_LIST                         = BASE_URL + "api/recipe/get-all-coach-recipe-list"
    static let GET_COACH_CLASS_PREVIOUS_LIST                         = BASE_URL + "api/coach-class/get-user-previous-list"
    static let GET_RECIPE_CLASS_PREVIOUS_LIST                         = BASE_URL + "api/recipe/get-user-previous-list"
    static let GET_SUBSCRIPTION_COACH_LIST                         = BASE_URL + "api/subscription/get-subscribed-coach-search-list"
    static let GET_FILTER_CLASS_LIST                         = BASE_URL + "api/get-filter-class-list"
    static let GET_COACH_CLASS_LIST                         = BASE_URL + "api/coach-class/get-all-coach-class-list"
    static let GET_MULTIPLE_CLASS_DETAILS                         = BASE_URL + "api/get-multiple-class-detail"
    static let GET_COACH_CLASS_RATING                         = BASE_URL + "api/coach-class/get-rating"
    static let GET_COACH_WISE_CLASS_LIST                         = BASE_URL + "api/coach/get-coach-wise-class-list"
    static let GET_COACH_WISE_RECIPE_LIST                         = BASE_URL + "api/coach/get-coach-wise-recipe-list"
    static let GET_COACH_SEARCH_HISTORY                         = BASE_URL + "api/coach/add-coach-search-history"
    static let ADD_REMOVE_FOLLOWERS                         = BASE_URL + "api/coach/add-remove-followers"

    static let ADD_USER_TO_COACH = BASE_URL + "api/subscription/add-user-to-coach"
    static let UNSUBSCRIBE_TO_COACH = BASE_URL + "api/subscription/unsubscribe-to-coach"

}

// MARK: - PARAMS KEYS

struct Params {
    struct Login {
        static let google_id = "google_id"
        static let login_type = "login_type"
        static let facebook_id = "facebook_id"
    }
    
    struct AddRemoveBookmark {
        static let coach_recipe_id = "coach_recipe_id"
        static let bookmark = "bookmark"
        static let coach_class_id = "coach_class_id"
    }
}

struct BookmarkType {
    static let Yes = "yes"
    static let No = "no"
}

struct LoginType {
    static let Facebook = 2
    static let Google = 1
    static let Standard = 0
}

// MARK: - RESPONSE CODE

struct RESPONSE_CODE {
    static let SUCCESS  = 200
}

// MARK: - APP COLORS

struct COLORS {
    static let APP_COLOR_LIGHT_GRAY     = hexStringToUIColor(hex: "#FFFCFC")
    static let APP_THEME_COLOR      = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    static let APP_COLOR_MEDIUM_GRAY    = #colorLiteral(red: 0.6745098039, green: 0.6901960784, blue: 0.7254901961, alpha: 1)
    static let TEXT_COLOR = UIColor.white
    static let TEXTFIELD_COLOR = hexStringToUIColor(hex: "#525F6F")
    static let VIEW_BG_COLOR = hexStringToUIColor(hex: "#2C3949")
    static let THEME_RED = hexStringToUIColor(hex: "#CC2936")
    static let TABBAR_COLOR = hexStringToUIColor(hex: "#828990")
    static let BLUR_COLOR = hexStringToUIColor(hex: "#2C3A4A")
}

// MARK: - ALERT TITLE

struct ALERT_BUTTON_TITLE {
    static let OK          = "Ok"
    static let CANCEL          = "Cancel"
}

//MARK: - CONSTANT

struct CONSTANTS {
    static let UN_AUTHORIZE_ACCESS  = "Unauthorized Access!"
    static let SOMETHING_WENT_WRONG         = "Ooops!! Something went wrong, please try after some time!"
    static let CHECK_INTERNET_CONNECTION    = "The request timed out, please verify your internet connection and try again."
    static var VERIFY_INTERNET_CONNECTION   = "Please check your internet connection and try again."
    static let NET_CONNECTION_LOST          = "Network lost"
    static var NO_INTERNET_CONNECTION       = "No internet connection"
    static let Select_your_country = "Select your country"
    static let Search = "Search"
}


struct CoachClassType {
    static let live          = "live"
    static let onDemand          = "on_demand"
}

struct UserRole {
    static let coach          = "coach"
    static let user          = "user"
}



var COGNITO_POOL_ID = "us-east-1:0e74eb1e-5f9f-4f32-94fa-a76e99140dd4"
var MY_REGION = "us-east-1"
var BUCKET_NAME = "class-resources/coach_trailer"
let GOOGLE_CLIENT_ID = "865862274412-bgpqh1lqatmuo12r1qkr97atabcipddl.apps.googleusercontent.com"

//
//
//
//struct COACH_CLASS_TYPE {
//    static let live = "live"
//    static let on_demand = "on_demand"
//
//}
