//FlutterのウィジェットとFirebaseの機能をインポート
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';
import 'add_page.dart';

//Firebaseの初期化、アプリケーションを起動
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

//テーマとホームページを設定
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '誕生年リスト',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '誕生年リスト'),
    );
  }
}

// Firebaseからデータを取得
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String firebaseText = '';
  List<User> users = [];

  @override
  void initState() {
    super.initState();

    _fetchFirebaseData();
  }

  void _fetchFirebaseData() async {
    final db = FirebaseFirestore.instance;
    final event = await db.collection("users").get();
    final docs = event.docs;
    final users = docs.map((doc) => User.fromFirestore(doc)).toList();

    setState(() {
      this.users = users;
    });
  }

// 非同期処理、データベースからデータを取得・保存する場合の非同期処理。
// データベースアクセスは時間がかかるため、非同期処理を使ってUIの応答性を維持しながらデータベースをやり取りする
  void _goToAddPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPage()),
    );
    _fetchFirebaseData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ヘッダー
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      //Firebaseから取得したユーザーデータをListViewとして表示
      //ListTileにて名前、姓、誕生年が表示
      body: ListView(
        children: users
            .map(
              (user) => ListTile(
                  title: Text(user.first),
                  subtitle: Text(user.last),
                  trailing: Text(user.born.toString()),
                  //onTap時、ユーザーがListTileをタップしたときに呼び出されるメソッド
                  //ダイアログを表示してユーザーに新しい誕生年を選択させ、その値をFirebaseに保存
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Select Year"),
                          content: Container(
                            width: 300,
                            height: 300,
                            child: YearPicker(
                              firstDate: DateTime(DateTime.now().year - 300, 1),
                              lastDate: DateTime(DateTime.now().year + 100, 1),
                              selectedDate: DateTime(user.born),
                              onChanged: (DateTime dateTime) {
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.id)
                                    .update({
                                  'born': dateTime.year,
                                });
                                Navigator.pop(context);
                                _fetchFirebaseData();
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                  //onLongPress時、ユーザーがListTileを長押ししたときに呼び出されるメソッド
                  //ダイアログを表示してユーザーに削除の確認を求め、'はい'を選択した場合、そのユーザーをFirebaseから削除
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('本当に削除しますか？'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('いいえ'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('はい'),
                              onPressed: () async {
                                final db = FirebaseFirestore.instance;
                                await db
                                    .collection("users")
                                    .doc(user.id)
                                    .delete();
                                _fetchFirebaseData();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }),
            )
            .toList(),
      ),
      //画面の右下に表示される丸いボタン
      //ボタン押下時、新しいユーザーを追加するページに遷移
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddPage,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
