# Mục lục toàn bộ file và hàm chính

Đây là mục lục khai báo tự lấy theo code hiện tại. Tên lớp State có dấu _ là private trong thư viện Dart; phương thức cùng tên ở các lớp khác nhau không phải một hàm duy nhất. Các callback ẩn danh nằm trong build hoặc hàm cha, nên không phải lúc nào có tên riêng ở bảng.

| File | Số dòng | Lớp và hàm khai báo |
| --- | --- | --- |
| [cuoiki/SurveyApi/Api/Controllers/AuthController.cs](<../cuoiki/SurveyApi/Api/Controllers/AuthController.cs>) — dòng 1 | 81 | `AuthController` L13; `Register` L16; `Login` L32; `Me` L50; `ChangePassword` L58; `Logout` L73; `PublicMember` L79 |
| [cuoiki/SurveyApi/Api/Controllers/CampaignController.cs](<../cuoiki/SurveyApi/Api/Controllers/CampaignController.cs>) — dòng 1 | 73 | `CampaignController` L11; `Get` L16; `Details` L28; `Status` L36; `Submit` L44; `Results` L54 |
| [cuoiki/SurveyApi/Api/Controllers/CategoryController.cs](<../cuoiki/SurveyApi/Api/Controllers/CategoryController.cs>) — dòng 1 | 55 | `CategoryController` L10; `Get` L12; `Add` L14; `Update` L30; `Delete` L49 |
| [cuoiki/SurveyApi/Api/Controllers/MemberController.cs](<../cuoiki/SurveyApi/Api/Controllers/MemberController.cs>) — dòng 1 | 42 | `MemberController` L10; `Get` L12; `Roles` L13; `Update` L16; `Delete` L26 |
| [cuoiki/SurveyApi/Api/Controllers/PlanController.cs](<../cuoiki/SurveyApi/Api/Controllers/PlanController.cs>) — dòng 1 | 33 | `PlanController` L10; `Get` L13; `Put` L15; `Delete` L21; `Checkout` L27 |
| [cuoiki/SurveyApi/Api/Controllers/SurveyController.cs](<../cuoiki/SurveyApi/Api/Controllers/SurveyController.cs>) — dòng 1 | 74 | `SurveyController` L10; `Get` L13; `Details` L18; `Related` L24; `Add` L32; `Update` L49; `Delete` L68 |
| [cuoiki/SurveyApi/Api/Models/BaseRepository.cs](<../cuoiki/SurveyApi/Api/Models/BaseRepository.cs>) — dòng 1 | 8 | `BaseRepository` L5 |
| [cuoiki/SurveyApi/Api/Models/CampaignRepository.cs](<../cuoiki/SurveyApi/Api/Models/CampaignRepository.cs>) — dòng 1 | 95 | `CampaignRepository` L7; `GetPlan` L9; `PutPlan` L12; `RemovePlan` L23; `Checkout` L26; `GetPage` L47; `Find` L61; `Items` L63; `SetStatus` L69; `Submit` L74; `Answers` L93 |
| [cuoiki/SurveyApi/Api/Models/CategoryRepository.cs](<../cuoiki/SurveyApi/Api/Models/CategoryRepository.cs>) — dòng 1 | 39 | `CategoryRepository` L6; `GetAll` L8; `Add` L9; `Update` L13; `Delete` L27 |
| [cuoiki/SurveyApi/Api/Models/Member.cs](<../cuoiki/SurveyApi/Api/Models/Member.cs>) — dòng 1 | 38 | `Member` L5; `LoginModel` L16; `RegisterModel` L22; `ChangePasswordModel` L27; `UpdateMemberModel` L33 |
| [cuoiki/SurveyApi/Api/Models/MemberRepository.cs](<../cuoiki/SurveyApi/Api/Models/MemberRepository.cs>) — dòng 1 | 53 | `MemberRepository` L6; `FindByEmail` L8; `FindById` L14; `Add` L20; `GetMembers` L28; `GetRoles` L34; `ChangePassword` L36; `Logout` L40; `Update` L43; `Delete` L51 |
| [cuoiki/SurveyApi/Api/Models/SiteProvider.cs](<../cuoiki/SurveyApi/Api/Models/SiteProvider.cs>) — dòng 1 | 17 | `SiteProvider` L5; `Dispose` L16 |
| [cuoiki/SurveyApi/Api/Models/Survey.cs](<../cuoiki/SurveyApi/Api/Models/Survey.cs>) — dòng 1 | 105 | `Category` L6; `CategoryForm` L14; `Survey` L22; `Question` L37; `SurveyForm` L46; `PageResult` L55; `TargetModel` L57; `CheckoutModel` L62; `ResponseModel` L68; `StatusModel` L74; `PlanItem` L79; `Campaign` L87; `CampaignItem` L97 |
| [cuoiki/SurveyApi/Api/Models/SurveyRepository.cs](<../cuoiki/SurveyApi/Api/Models/SurveyRepository.cs>) — dòng 1 | 69 | `SurveyRepository` L6; `GetPage` L14; `Find` L23; `Related` L25; `Add` L34; `Update` L41; `Delete` L57 |
| [cuoiki/SurveyApi/Api/Models/SurveyRules.cs](<../cuoiki/SurveyApi/Api/Models/SurveyRules.cs>) — dòng 1 | 51 | `SurveyRules` L5; `ValidateQuestions` L7; `ValidateAnswers` L30 |
| [cuoiki/SurveyApi/Program.cs](<../cuoiki/SurveyApi/Program.cs>) — dòng 1 | 77 | Cấu hình/khai báo đầu chương trình |
| [cuoiki/SurveyApi/Services/ImageService.cs](<../cuoiki/SurveyApi/Services/ImageService.cs>) — dòng 1 | 32 | `ImageService` L3; `Save` L5; `Delete` L25 |
| [cuoiki/survey_app/lib/local/local_database.dart](<../cuoiki/survey_app/lib/local/local_database.dart>) — dòng 1 | 93 | `LocalDatabase` L4; `open` L6; `close` L28; `_createDrafts` L33; `saveDraft` L40; `draft` L56; `drafts` L65; `deleteDraft` L72; `clearDrafts` L80 |
| [cuoiki/survey_app/lib/main.dart](<../cuoiki/survey_app/lib/main.dart>) — dòng 1 | 62 | `main` L10; `SurveyApp` L26; `build` L30; `_SessionPage` L42; `_SessionPageState` L45; `_SessionPageState` L48; `build` L51 |
| [cuoiki/survey_app/lib/models/member.dart](<../cuoiki/survey_app/lib/models/member.dart>) — dòng 1 | 19 | `Member` L1 |
| [cuoiki/survey_app/lib/models/survey.dart](<../cuoiki/survey_app/lib/models/survey.dart>) — dòng 1 | 114 | `Category` L1; `Question` L12; `toMap` L31; `Survey` L40; `toMap` L41; `PlanItem` L68; `Campaign` L77; `statusText` L87; `CampaignItem` L97; `PageData` L110 |
| [cuoiki/survey_app/lib/pages/campaign_details_page.dart](<../cuoiki/survey_app/lib/pages/campaign_details_page.dart>) — dòng 1 | 197 | `CampaignDetailsPage` L9; `_CampaignDetailsPageState` L19; `_CampaignDetailsPageState` L22; `initState` L28; `_load` L33; `_status` L61; `build` L85 |
| [cuoiki/survey_app/lib/pages/campaign_list_page.dart](<../cuoiki/survey_app/lib/pages/campaign_list_page.dart>) — dòng 1 | 210 | `CampaignListPage` L8; `_CampaignListPageState` L18; `_CampaignListPageState` L21; `initState` L30; `dispose` L36; `_date` L41; `_load` L44; `_apply` L74; `_pickDate` L80; `build` L98 |
| [cuoiki/survey_app/lib/pages/category_page.dart](<../cuoiki/survey_app/lib/pages/category_page.dart>) — dòng 1 | 296 | `CategoryPage` L12; `_CategoryPageState` L15; `_CategoryPageState` L18; `initState` L23; `_load` L28; `_edit` L43; `_delete` L55; `build` L75; `_CategoryDialog` L125; `_CategoryDialogState` L129; `_CategoryDialogState` L132; `initState` L140; `dispose` L147; `_save` L153; `_pickImage` L178; `build` L207 |
| [cuoiki/survey_app/lib/pages/change_password_page.dart](<../cuoiki/survey_app/lib/pages/change_password_page.dart>) — dòng 1 | 111 | `ChangePasswordPage` L8; `_ChangePasswordPageState` L12; `_ChangePasswordPageState` L15; `dispose` L23; `_save` L30; `build` L60 |
| [cuoiki/survey_app/lib/pages/drafts_page.dart](<../cuoiki/survey_app/lib/pages/drafts_page.dart>) — dòng 1 | 99 | `DraftsPage` L9; `_DraftsPageState` L13; `_DraftsPageState` L16; `initState` L21; `_load` L26; `build` L40 |
| [cuoiki/survey_app/lib/pages/home_page.dart](<../cuoiki/survey_app/lib/pages/home_page.dart>) — dòng 1 | 212 | `HomePage` L17; `_HomePageState` L21; `_HomePageState` L24; `initState` L30; `_refreshPlan` L35; `_open` L44; `_logout` L52; `build` L107 |
| [cuoiki/survey_app/lib/pages/login_page.dart](<../cuoiki/survey_app/lib/pages/login_page.dart>) — dòng 1 | 183 | `LoginPage` L9; `_LoginPageState` L12; `_LoginPageState` L15; `dispose` L23; `_submit` L30; `build` L79 |
| [cuoiki/survey_app/lib/pages/member_page.dart](<../cuoiki/survey_app/lib/pages/member_page.dart>) — dòng 1 | 244 | `MemberPage` L6; `_MemberPageState` L10; `_MemberPageState` L13; `initState` L19; `_load` L24; `_edit` L47; `_delete` L151; `build` L187 |
| [cuoiki/survey_app/lib/pages/plan_page.dart](<../cuoiki/survey_app/lib/pages/plan_page.dart>) — dòng 1 | 260 | `PlanPage` L8; `_PlanPageState` L13; `_PlanPageState` L16; `initState` L24; `dispose` L30; `_load` L35; `_target` L50; `_remove` L70; `_checkout` L89; `build` L127; `_TargetDialog` L206; `_TargetDialogState` L210; `_TargetDialogState` L213; `initState` L217; `dispose` L223; `build` L229 |
| [cuoiki/survey_app/lib/pages/response_page.dart](<../cuoiki/survey_app/lib/pages/response_page.dart>) — dòng 1 | 249 | `ResponsePage` L11; `_ResponsePageState` L21; `_ResponsePageState` L24; `initState` L31; `_load` L36; `_store` L58; `_save` L68; `_submit` L84; `_question` L131; `build` L213 |
| [cuoiki/survey_app/lib/pages/results_page.dart](<../cuoiki/survey_app/lib/pages/results_page.dart>) — dòng 1 | 112 | `ResultsPage` L6; `_ResultsPageState` L16; `_ResultsPageState` L19; `initState` L24; `_load` L29; `build` L48 |
| [cuoiki/survey_app/lib/pages/server_settings_page.dart](<../cuoiki/survey_app/lib/pages/server_settings_page.dart>) — dòng 1 | 124 | `ServerSettingsPage` L6; `_ServerSettingsPageState` L9; `_ServerSettingsPageState` L12; `dispose` L18; `_check` L23; `build` L51 |
| [cuoiki/survey_app/lib/pages/survey_details_page.dart](<../cuoiki/survey_app/lib/pages/survey_details_page.dart>) — dòng 1 | 257 | `SurveyDetailsPage` L10; `_SurveyDetailsPageState` L19; `_SurveyDetailsPageState` L22; `initState` L31; `_load` L36; `_loadRelated` L55; `_addPlan` L78; `_delete` L98; `build` L120 |
| [cuoiki/survey_app/lib/pages/survey_edit_page.dart](<../cuoiki/survey_app/lib/pages/survey_edit_page.dart>) — dòng 1 | 365 | `SurveyEditPage` L8; `_SurveyEditPageState` L12; `_SurveyEditPageState` L15; `initState` L25; `dispose` L35; `_load` L41; `_pickImage` L60; `_editQuestion` L75; `_save` L96; `build` L128; `QuestionDialog` L241; `_QuestionDialogState` L252; `_QuestionDialogState` L255; `initState` L261; `dispose` L270; `_save` L276; `build` L298 |
| [cuoiki/survey_app/lib/pages/survey_list_view.dart](<../cuoiki/survey_app/lib/pages/survey_list_view.dart>) — dòng 1 | 245 | `SurveyListView` L11; `_SurveyListViewState` L22; `_SurveyListViewState` L25; `initState` L35; `dispose` L41; `_load` L46; `_details` L78; `_add` L93; `build` L106 |
| [cuoiki/survey_app/lib/repositories/campaign_repository.dart](<../cuoiki/survey_app/lib/repositories/campaign_repository.dart>) — dòng 1 | 90 | `CampaignRepository` L6; `newId` L7; `plan` L16; `putPlan` L20; `removePlan` L24; `checkout` L28; `getPage` L34; `details` L60; `status` L64; `submit` L68; `results` L81 |
| [cuoiki/survey_app/lib/repositories/member_repository.dart](<../cuoiki/survey_app/lib/repositories/member_repository.dart>) — dòng 1 | 105 | `MemberRepository` L9; `request` L10; `changePassword` L16; `logout` L23; `getMembers` L34; `getRoles` L41; `updateMember` L43; `deleteMember` L56; `_post` L60; `login` L81; `register` L94 |
| [cuoiki/survey_app/lib/repositories/survey_repository.dart](<../cuoiki/survey_app/lib/repositories/survey_repository.dart>) — dòng 1 | 114 | `SurveyRepository` L10; `categories` L11; `saveCategory` L15; `deleteCategory` L41; `getPage` L45; `related` L67; `details` L80; `delete` L85; `save` L89 |
| [cuoiki/survey_app/lib/services/api_service.dart](<../cuoiki/survey_app/lib/services/api_service.dart>) — dòng 1 | 140 | `ApiService` L9; `normalizeUrl` L20; `initialize` L38; `saveServer` L43; `checkServer` L49; `upload` L74; `request` L90; `imageUrl` L139 |
| [cuoiki/survey_app/lib/services/session_helper.dart](<../cuoiki/survey_app/lib/services/session_helper.dart>) — dòng 1 | 32 | `SessionHelper` L7; `save` L9; `restore` L15; `clear` L28 |
| [cuoiki/survey_app/lib/widgets/category_image.dart](<../cuoiki/survey_app/lib/widgets/category_image.dart>) — dòng 1 | 27 | `CategoryImage` L5; `build` L10 |
| [cuoiki/survey_app/lib/widgets/common.dart](<../cuoiki/survey_app/lib/widgets/common.dart>) — dòng 1 | 62 | `errorText` L3; `showMessage` L5; `confirmAction` L8; `PageButtons` L32; `build` L42 |

## Tìm nhanh khi không nhớ file

Trong VS Code: Ctrl+P nhập tên file, Ctrl+G nhập số dòng, Ctrl+Shift+F tìm toàn workspace tên hàm/chuỗi thông báo. Nếu gặp hai CampaignRepository, chú ý đuôi .dart hoặc .cs. Chọn file trong cuoiki, tránh mở nhầm dự án trek_bikes_app hoặc WebApp tham khảo.

## Cấu hình Android và các file hỗ trợ

| File | Vai trò |
| --- | --- |
| [pubspec.yaml](<../cuoiki/survey_app/pubspec.yaml>) — dòng 1 | Tên/version package Dart, dependencies http, sqflite, Secure Storage, image_picker và test |
| [AndroidManifest.xml](<../cuoiki/survey_app/android/app/src/main/AndroidManifest.xml>) — dòng 1 | Tên hiển thị app, quyền Internet, icon và HTTP nội bộ |
| [ic_survey_launcher.xml](<../cuoiki/survey_app/android/app/src/main/res/drawable/ic_survey_launcher.xml>) — dòng 1 | Icon bảng khảo sát dạng vector XML, không phải ảnh upload của danh mục |
| [MainActivity.kt](<../cuoiki/survey_app/android/app/src/main/kotlin/vn/edu/doan/survey_app/MainActivity.kt>) — dòng 1 | Activity Android mở Flutter, không chứa nghiệp vụ khảo sát |
| [build.gradle.kts](<../cuoiki/survey_app/android/app/build.gradle.kts>) — dòng 1 | ApplicationId, version, cấu hình Android và ký bản release nội bộ |
| [gradle.properties](<../cuoiki/survey_app/android/gradle.properties>) — dòng 1 | Cấu hình Gradle/Kotlin phục vụ build |
| [SurveyApi.csproj](<../cuoiki/SurveyApi/SurveyApi.csproj>) — dòng 1 | Target net10.0, package Dapper/JWT/SqlClient/BCrypt và adb reverse khi build Debug |
| [launchSettings.json](<../cuoiki/SurveyApi/Properties/launchSettings.json>) — dòng 1 | Cổng 5080, môi trường Development và địa chỉ lắng nghe |
| [enable-wifi.ps1](<../cuoiki/enable-wifi.ps1>) — dòng 1 | Quy tắc firewall cổng 5080 cho mạng nội bộ, chạy Administrator |
| [widget_test.dart](<../cuoiki/survey_app/test/widget_test.dart>) — dòng 1 | Kiểm thử giao diện, quyền hiển thị, validation và layout |
| [server_settings_test.dart](<../cuoiki/survey_app/test/server_settings_test.dart>) — dòng 1 | Kiểm thử URL, lưu cấu hình và form kết nối |
| [local_database_test.dart](<../cuoiki/survey_app/test/local_database_test.dart>) — dòng 1 | Kiểm thử nháp SQLite và nâng schema |
| [full_api_check.ps1](<../cuoiki/tests/full_api_check.ps1>) — dòng 1 | Kiểm thử API với dữ liệu/tài khoản tạm và dọn sau khi chạy |
| [001_initial.sql](<../cuoiki/SurveyApi/Database/001_initial.sql>) — dòng 1 | Script schema/cấp quyền; riêng 003 là thao tác Admin thủ công |
| [002_member_management.sql](<../cuoiki/SurveyApi/Database/002_member_management.sql>) — dòng 1 | Script schema/cấp quyền; riêng 003 là thao tác Admin thủ công |
| [003_first_admin.sql](<../cuoiki/SurveyApi/Database/003_first_admin.sql>) — dòng 1 | Script schema/cấp quyền; riêng 003 là thao tác Admin thủ công |
| [004_surveys_campaigns.sql](<../cuoiki/SurveyApi/Database/004_surveys_campaigns.sql>) — dòng 1 | Script schema/cấp quyền; riêng 003 là thao tác Admin thủ công |
| [005_category_images.sql](<../cuoiki/SurveyApi/Database/005_category_images.sql>) — dòng 1 | Script schema/cấp quyền; riêng 003 là thao tác Admin thủ công |

ConnectionStrings, Jwt Issuer/Audience và cấu hình môi trường nằm trong appsettings hoặc biến môi trường của API. Không sao chép giá trị bí mật/khóa local vào tài liệu ôn. APK release ở cuoiki/survey_app/build/app/outputs/flutter-apk/app-release.apk; đây là đầu ra build, không phải nguồn nghiệp vụ.
