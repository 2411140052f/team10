team10 高崎健心　吉留奏梧

ユーザーストーリー

①学生:落とし物が届けられたときに見つけやすいように、物の名前,色,特徴,拾得場所から忘れ物を検索したい

②学生:探している物が一覧にない場合でも学校職員や他生徒に情報を伝えられるように、なくした物の名前・特徴・日時・場所などを入力して捜索願を登録したい

③職員:届けられた忘れ物を適切に管理するため、物の写真・名前・特徴・拾得場所・日時などを登録したい

④職員:忘れ物の問い合わせに対応しやすくするため、学生から登録された捜索願を一覧で確認したい

⑤職員:忘れ物の管理状況を把握するため、受け取り前・受け取り済みなどのステータスを変更・管理したい

画面遷移
![alt text](image.png)

ワイヤーフレーム
![alt text](image-2.png)
![alt text](image-1.png)
![alt text](image-3.png)

モデル案
Staffモデル:username,password role:職員

LostItemモデル：name, found_place, found_at, feature, category, status, handed_over_at, staff_id, 写真

MissingReport:code(自動生成ID), name, lost_place, lost_at, feature, category, 写真

DeletionRequest	:missing_report_id
