import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/core/constants/app_constants.dart';
import 'package:shopping_app/features/admin/widgets/user_proplem_card.dart';

class UserProblemPage extends StatefulWidget {
  const UserProblemPage({super.key});
  static const String id = 'UserProplemPage';

  @override
  _UserProblemPageState createState() => _UserProblemPageState();
}

enum FilterType { all, read, unread }

class _UserProblemPageState extends State<UserProblemPage> {
  FilterType _filterType = FilterType.all;

  Stream<QuerySnapshot> _getMessages() {
    final collection = FirebaseFirestore.instance
        .collection('messages')
        .orderBy('timestamp', descending: true);

    if (_filterType == FilterType.read) {
      return collection.where('isRead', isEqualTo: true).snapshots();
    } else if (_filterType == FilterType.unread) {
      return collection.where('isRead', isEqualTo: false).snapshots();
    } else {
      return collection.snapshots(); // all
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text("مشاكل المستخدمين", style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: kBackgroundGradientAppbar),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DropdownButton<FilterType>(
                  value: _filterType,
                  onChanged: (FilterType? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _filterType = newValue;
                      });
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: FilterType.all,
                      child: Text("الكل"),
                    ),
                    DropdownMenuItem(
                      value: FilterType.read,
                      child: Text("مقروءة"),
                    ),
                    DropdownMenuItem(
                      value: FilterType.unread,
                      child: Text("غير مقروءة"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getMessages(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('حدث خطأ في تحميل البيانات'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('لا توجد رسائل حالياً'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var message = snapshot.data!.docs[index];
                    return UserProblemCard(message: message);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
