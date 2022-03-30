// swiftlint:disable identifier_name

import Foundation
import UIKit

let formatter = NumberFormatter()
var DEFAULTS = UserDefaults.standard
let APPDELEGATE = UIApplication.shared.delegate as! AppDelegate

// MARK: - API URL

struct DEFAULTS_KEY {
    static let FCM_TOKEN = "device_token"
    static let AUTH_TOKEN = "Authorization"
    static let USER_DATA = "LoginUserData"
    static let USER_ID = "UserId"
    static let USERNAME = "UserName"
    static let USER_PASSWORD = "UserPassword"
    static let IS_REMEMBER_ME = "isRememberMe"
}

struct STRIPE_API {
    static let BASE_URL = "https://api.stripe.com/v1/"

    static let payment_methods = BASE_URL + "payment_methods"
    static let payment_intents = BASE_URL + "payment_intents"
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
    static let RECIPE_DELETE                           = BASE_URL + "api/recipe/delete/"
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
    static let GET_USER_BOOKMARK_LIST                        = BASE_URL + "api/recipe/get-user-bookmark-list"
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
    static let FOLLOWING_COACH_CLASS_LIST = BASE_URL + "api/coach-class/following-coach-class-list"
    static let FOLLOWING_COACH_RECIPE_LIST = BASE_URL + "api/recipe/following-coach-recipe-list"
    static let GET_MY_COACH_CLASS_LIST = BASE_URL + "api/get-my-coach-class-list"
    static let ADD_USER_TO_COACH_CLASS = BASE_URL + "api/subscription/add-user-to-coach-class"
    static let CHECK_USER_SUBSCRIBED_CLASS = BASE_URL + "api/subscription/check-user-subscribed-class"
    static let JOIN_SESSION = BASE_URL + "api/coach-class/join-sessions"
    static let END_LIVE_CLASS = BASE_URL + "api/coach-class/end-live-class"
    static let NEW_UPLOAD = BASE_URL + "api/coach/new-uploads"
    static let LIST_OF_CLASS_DONE = BASE_URL + "api/coach/list-of-class-done"
    static let GET_COACH_SUBSCRIBER_USER_SEARCH_LIST = BASE_URL + "api/subscription/get-coach-subscriber-user-search-list"
    static let MEAL_TYPE_AND_DIETARY_RESTRICTION_LIST = BASE_URL + "api/meal-type-and-dietary-restriction-list"
    static let GET_USER_WORKOUT_STATISTIC = BASE_URL + "api/auth/get-user-workout-statistics"
    static let GET_USER_PREVIOUS_CLASS = BASE_URL + "api/auth/get-user-previous-class"
    static let GET_AWS_DETAILS = BASE_URL + "api/coach-class/aws-details"
    static let GET_NOTIFICATION_LIST = BASE_URL + "api/notification-list"
    
    
}

// MARK: - PARAMS KEYS

enum StripeConstant : String {
    case Secret_key = "sk_test_51K7Y7mSD6FO6JDp9leFH54xc3eC116doMwtXV5oehkEA75EKVuuJMOkVl1JyVUtYUvLenlU7Zsh3GEq5CNfVdyWP00KnMrIvg1"
    case Publishable_key = "pk_test_51K7Y7mSD6FO6JDp9JVBJCXDqH84LNDhdGwWEeJzdjJSLCYugjje1svaFLrykhoAbP7DYNW215N8a8TXgjxaQOzpS00mlApAIZc"
    case CallBack_URL = "http://healthline.brainbinaryinfotech.com/hook"
}

struct StripeParams {
    struct PaymentMethods {
        static let type = "type"
        static let card = "card"
        static let metadata = "metadata"
        static let billing_details = "billing_details"
    }
    
    struct Card {
        static let number = "number"
        static let exp_month = "exp_month"
        static let exp_year = "exp_year"
        static let cvc = "cvc"
    }
    
    struct Metadata {
        static let holder_name = "holder_name"
        static let card_number = "card_number"
        static let card_type = "card_type"
    }
    
    struct BillingDetails {
        static let address = "address"
        struct Address {
            static let city = "city"
            static let country = "country"
            static let line1 = "line1"
            static let line2 = "line2"
            static let postal_code = "postal_code"
            static let state = "state"
        }
        static let email = "email"
        static let name = "name"
        static let phone = "phone"
    }
    
    struct PaymentMethodsAttach {
        static let customer = "customer"
    }
    
    struct Cards {
        static let type = "type"
        static let customer = "customer"
    }
    
    struct PaymentIntents {
        static let amount = "amount"
        static let currency = "currency"
        static let customer = "customer"
        static let payment_method = "payment_method"
        static let confirm = "confirm"
    }
    
    struct PaymentIntentsConfirm {
        static let intent = "intent"
        static let payment_method = "payment_method"
        static let return_url = "return_url"
    }
}

struct Params {
    struct Login {
        static let google_id = "google_id"
        static let login_type = "login_type"
        static let facebook_id = "facebook_id"
        static let device_token = "device_token"
    }
    
    struct AddRemoveBookmark {
        static let coach_recipe_id = "coach_recipe_id"
        static let bookmark = "bookmark"
        static let coach_class_id = "coach_class_id"
    }
    
    struct GetMyCoachClassList {
        static let page_no = "page_no"
        static let per_page = "per_page"
    }
    
    struct JoinSessions {
        static let coach_class_subscription_id = "coach_class_subscription_id"
        static let class_id = "class_id"
    }
    
    struct EndLiveClass {
        static let class_id = "class_id"
        static let duration = "duration"
        static let user_coach_history_id = "user_coach_history_id"
    }
}

struct BookmarkType {
    static let Yes = "yes"
    static let No = "no"
}

enum LoginTypeConst: Int {
    case Facebook = 2
    case Google = 1
    case Standard = 0
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
    
    static let ON_DEMAND_COLOR = hexStringToUIColor(hex: "#1A82F6")
    static let RECIPE_COLOR = hexStringToUIColor(hex: "#4DB748")
    static let CHART_BG_COLOR = hexStringToUIColor(hex: "#707070")
    static let BARCHART_BG_COLOR = hexStringToUIColor(hex: "#E200FF")
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
