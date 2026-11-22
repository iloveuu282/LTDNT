-- Schema SQLite phiên bản 2 hiện tại; tham khảo lib/local/local_database.dart.
-- Đây là schema trống để giải trình, không phải dữ liệu từ điện thoại.
CREATE TABLE survey_drafts (
    member_id INTEGER NOT NULL,
    survey_id INTEGER NOT NULL,
    answers_json TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    PRIMARY KEY(member_id, survey_id)
);
CREATE TABLE response_drafts (
    member_id INTEGER NOT NULL,
    item_id INTEGER NOT NULL,
    campaign_id INTEGER NOT NULL,
    payload_json TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    PRIMARY KEY(member_id, item_id)
);
