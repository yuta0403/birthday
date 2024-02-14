//FlutterのウィジェットとFirebaseの機能
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  AddPageState createState() => AddPageState();
}

// AddPageの状態を管理するクラス
// ユーザーの入力を受け取り、Firebaseに保存
class AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  int _selectedYear = DateTime.now().year;

// 2つのテキストフィールドと1つのドロップダウンメニュー
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新規追加'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: '名字'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: '名前'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              //ユーザーの誕生年を選択するためのメニュー。
              //現在の年から100年前までの値が選択可能。
              DropdownButton<int>(
                value: _selectedYear,
                items: List<int>.generate(100, (i) => DateTime.now().year - i)
                    .map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedYear = newValue!;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    FirebaseFirestore.instance.collection('users').add({
                      'first': _firstNameController.text,
                      'last': _lastNameController.text,
                      'born': _selectedYear,
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text('登録'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}