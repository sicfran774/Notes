import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:notes_bootstrap/login.dart';
import 'package:notes_bootstrap/note.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late final TextEditingController textController;
  late List<Note> notesList;

  @override
  void initState() {
    textController = TextEditingController();
  }

  Future loadNotesFromFirebase() async {
    //Start from scratch
    List<Note> temp = [];
    //Get current logged-in user's note data from Firebase Realtime Database
    try{
      await FirebaseDatabase.instance.ref("users/testUser").once().then((data) {
        //Convert retrieved notes into map
        var map = data.snapshot.value as Map<dynamic, dynamic>;

        //Traverse through each key/value pair and create a new "Note" object
        map.forEach((key, value) {
          final note = Note.fromMap(value);

          //Finally add the note to the list
          temp.add(note);
        });
      });
    } catch (e) {
      print(e);
    }

    //Reverse the list because items are added from most recent to oldest
    temp = temp.reversed.toList();

    // temp.forEach((element) {
    //   print('${element.title}, ${element.words}');
    // });
    return temp;
  }

  void updateList() {
    setState(() {});
  }

  Future showNoteDialog(){
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("New Note"),
            content: TextField(
              controller: textController,
              decoration: const InputDecoration(helperText: "Note Title", hintText: "Type in a title for note"),
            ),
            actions: [
              TextButton(onPressed: () => createNote(textController.text), child: const Text("OK"))
            ],
          );
        }
    );
  }

  Future createNote(String title) async {
    //Use current time to get a unique note number
    var now = DateTime.now().millisecondsSinceEpoch.toString();
    await FirebaseDatabase.instance.ref("users/testUser/$now").ref.set({
      "noteName": now,
      "title": title,
      "words": "Default Text"
    }).then((value) {
      Navigator.pop(context); //Remove dialog
      Navigator.push(context, MaterialPageRoute(builder: (context) => NoteScreen(updateList: updateList, noteName: now, title: title, words: "Default Text")));
    });
    updateList();
  }

  void goToLoginPage(){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes",),
        backgroundColor: Colors.blue,
        elevation: 10,
      ),
      endDrawer: Drawer(
        child: ListView(
          children: [
            //Add a note
            ListTile(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Add a note"),
                  Icon(Icons.add_box_outlined),
                ],
              ),
              onTap: () {
                Navigator.pop(context);
                showNoteDialog();
              },
            ),
            //Sign out
            ListTile(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Sign Out"),
                  Icon(Icons.follow_the_signs_outlined),
                ],
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                goToLoginPage();
              },
            ),
          ],
        )
      ),
      body: refreshWidget(),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => setState(() {}),
        child: const Icon(Icons.refresh),),
    );
  }

  Widget refreshWidget() {
    return FutureBuilder(
      future: loadNotesFromFirebase(),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          notesList = snapshot.data;
          return ListView.builder( //Get each note and display it sequentially
            itemCount: notesList.length,
            itemBuilder: (context, index) {
              return ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  NoteScreen(
                      noteName: notesList[index].noteName,
                      title: notesList[index].title,
                      words: notesList[index].words,
                      updateList: updateList,))),
                  child: Text(notesList[index].title));
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },);
  }
}

class Note {

  final String noteName;
  final String title;
  final String words;

  const Note({
    required this.noteName,
    required this.title,
    required this.words,
  });

  //If called using a map it will return a Note object with those k's & v's
  factory Note.fromMap(Map<dynamic, dynamic> map) {
    return Note(
      noteName: map['noteName'] ?? '',
      title: map['title'] ?? '',
      words: map['words'] ?? '',
    );
  }
}
