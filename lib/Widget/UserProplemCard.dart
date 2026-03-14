import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProblemCard extends StatelessWidget {
  final QueryDocumentSnapshot message;

  const UserProblemCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    String userId = message['uid'];
    String phoneNumber = message['phone'] ?? 'غير متوفر';
    String messageText = message['message'] ?? 'لا يوجد محتوى';
    bool isRead = message['isRead'] ?? false;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var userData = snapshot.data;
        String firstName = userData?['first_name'] ?? 'غير معروف';
        String lastName = userData?['last_name'] ?? '';

        String userName = '$firstName $lastName';

        return Card(
          margin: EdgeInsets.all(8.0),
          elevation: 5,
          child: ListTile(
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    userName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (!isRead)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    bool confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("تأكيد الحذف"),
                        content: Text("هل تريد حذف هذه الرسالة؟"),
                        actions: [
                          TextButton(
                            child: Text("إلغاء"),
                            onPressed: () => Navigator.pop(context, false),
                          ),
                          TextButton(
                            child: Text("حذف"),
                            onPressed: () => Navigator.pop(context, true),
                          ),
                        ],
                      ),
                    );

                    if (confirm) {
                      await message.reference.delete();
                    }
                  },
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('رقم الهاتف: $phoneNumber'),
                SizedBox(height: 5),
                Text(
                  messageText.length > 30
                      ? '${messageText.substring(0, 30)}...'
                      : messageText,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            onTap: () async {
              // تحديث الرسالة كمقروءة
              if (!isRead) {
                await message.reference.update({'isRead': true});
              }

              _showMessageDetails(context, message, userName);
            },
          ),
        );
      },
    );
  }

  void _showMessageDetails(
    BuildContext context,
    QueryDocumentSnapshot message,
    String userName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(userName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${message['userEmail']}"),
            SizedBox(height: 10),
            Text("${message['phone']}"),
            SizedBox(height: 10),
            Text("${message['message']}"),
          ],
        ),
        actions: [
          TextButton(
            child: Text("إغلاق"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
