// class ExpenseEntity {
//
//   final String cost;
//   final int group_id;
//   final String description;
//   final String details;
//   final String date;
//   final String repeat_interval;
//   final String currency_code;
//   final int category_id;
//   final int id;
//   final int friendship_id;
//   final int expense_bundle_id;
//   final bool repeats;
//   final bool email_reminder;
//   final Object email_reminder_in_advance;
//   final String next_repeat;
//   final int comments_count;
//   final bool payment;
//   final bool transaction_confirmed;
//   // final List<Repayments> repayments;
//   final String created_at;
//   // final Created_by created_by;
//   final String updated_at;
//   // final Updated_by updated_by;
//   final String deleted_at;
//   // final Deleted_by deleted_by;
//   // final Category category;
//   // final Receipt receipt;
//   // final List<Users> users;
//   // final List<Comments> comments;
//
//   ExpenseEntity.fromJsonMap(Map<String, dynamic> map):
//         cost = map["cost"],
//         group_id = map["group_id"],
//         description = map["description"],
//         details = map["details"],
//         date = map["date"],
//         repeat_interval = map["repeat_interval"],
//         currency_code = map["currency_code"],
//         category_id = map["category_id"],
//         id = map["id"],
//         friendship_id = map["friendship_id"],
//         expense_bundle_id = map["expense_bundle_id"],
//         repeats = map["repeats"],
//         email_reminder = map["email_reminder"],
//         email_reminder_in_advance = map["email_reminder_in_advance"],
//         next_repeat = map["next_repeat"],
//         comments_count = map["comments_count"],
//         payment = map["payment"],
//         transaction_confirmed = map["transaction_confirmed"],
//         // repayments = List<Repayments>.from(map["repayments"].map((it) => Repayments.fromJsonMap(it))),
//         created_at = map["created_at"],
//         // created_by = Created_by.fromJsonMap(map["created_by"]),
//         updated_at = map["updated_at"],
//         // updated_by = Updated_by.fromJsonMap(map["updated_by"]),
//         deleted_at = map["deleted_at"]
//         // deleted_by = Deleted_by.fromJsonMap(map["deleted_by"]),
//         // category = Category.fromJsonMap(map["category"]),
//         // receipt = Receipt.fromJsonMap(map["receipt"]),
//         // users = List<Users>.from(map["users"].map((it) => Users.fromJsonMap(it))),
//         // comments = List<Comments>.from(map["comments"].map((it) => Comments.fromJsonMap(it)))
//   ;
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['cost'] = cost;
//     data['group_id'] = group_id;
//     data['description'] = description;
//     data['details'] = details;
//     data['date'] = date;
//     data['repeat_interval'] = repeat_interval;
//     data['currency_code'] = currency_code;
//     data['category_id'] = category_id;
//     data['id'] = id;
//     data['friendship_id'] = friendship_id;
//     data['expense_bundle_id'] = expense_bundle_id;
//     data['repeats'] = repeats;
//     data['email_reminder'] = email_reminder;
//     data['email_reminder_in_advance'] = email_reminder_in_advance;
//     data['next_repeat'] = next_repeat;
//     data['comments_count'] = comments_count;
//     data['payment'] = payment;
//     data['transaction_confirmed'] = transaction_confirmed;
//     // data['repayments'] = repayments != null ?
//     // this.repayments.map((v) => v.toJson()).toList()
//     //     : null;
//     data['created_at'] = created_at;
//     // data['created_by'] = created_by == null ? null : created_by.toJson();
//     data['updated_at'] = updated_at;
//     // data['updated_by'] = updated_by == null ? null : updated_by.toJson();
//     data['deleted_at'] = deleted_at;
//     // data['deleted_by'] = deleted_by == null ? null : deleted_by.toJson();
//     // data['category'] = category == null ? null : category.toJson();
//     // data['receipt'] = receipt == null ? null : receipt.toJson();
//     // data['users'] = users != null ?
//     // this.users.map((v) => v.toJson()).toList()
//     //     : null;
//     // data['comments'] = comments != null ?
//     // this.comments.map((v) => v.toJson()).toList()
//     //     : null;
//     // return data;
//   }
// }
//
