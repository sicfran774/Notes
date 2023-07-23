import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class NoteScreen extends StatefulWidget {
  final String userId;
  final String noteName;
  final String title;
  final String words;
  final Function() updateList;

  const NoteScreen({required this.userId, required this.noteName, required this.title, required this.words, required this.updateList, super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {

  late TextEditingController textController;
  late String userId;
  late String noteName;
  late String title;
  late String words;
  late Function() updateList;

  @override
  void initState(){
    textController = TextEditingController();
    userId = widget.userId;
    noteName = widget.noteName;
    title = widget.title;
    words = widget.words;
    updateList = widget.updateList;

    if(words.isNotEmpty){
      textController.text = words;
    }
  }

  void saveNote(String noteName, String title, String words) async {
    await FirebaseDatabase.instance.ref("users/$userId/$noteName").ref.update({
      "title": title,
      "words": words
    });
    await updateList();
  }

  void deleteNote(String noteName) async {
    await FirebaseDatabase.instance.ref("users/$userId/$noteName").ref.remove();
    await updateList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(onPressed: () {
              deleteNote(noteName);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: textController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          saveNote(noteName, title, textController.text);
          Navigator.pop(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}

