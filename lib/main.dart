import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class PickMyImage{
  static Future<File> getImage() async {
    final image = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      return File(image.path);
    }
    return null;
  }
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

/*class ConfirmLogin extends StatefulWidget{
  ConfirmLogin();
  @override
  _ConfirmLoginState createState() => _ConfirmLoginState();
}

class _ConfirmLoginState extends State<ConfirmLogin>{
  String _confirm;
  @override
  Widget build(BuildContext context) {
    return
  }
}*/

class LoginScreen extends StatefulWidget {
  final stored;
  bool isLoggedIn;

  LoginScreen(this.isLoggedIn, this.stored);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _emailAddress, _password;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  _LoginScreenState();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text('Login'),
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.all(25.0),
                      child: (Text(
                        'Welcome to Startup Names Generator, please log in below',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ))),
                  const SizedBox(height: 42),
                  TextField(
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                    onChanged: (String str) {
                      _emailAddress = str;
                      _RandomWordsState.currAddress = str;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                    onChanged: (String str) {
                      _password = str;
                    },
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                      color: Colors.red,
                      textColor: Colors.white,
                      onPressed: () => _handleLogin(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text('Log in', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                      color: Colors.teal,
                      textColor: Colors.white,
                      onPressed: () => _handleRegister(context),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text('New user? Click to sign up', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ],
              ),
            )),
        onWillPop: () {
          Navigator.pop(context, widget.isLoggedIn);
          return Future.value(false);
        });
  }

  Future<void> _handleLogin(context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailAddress, password: _password);
      onLogIn();
    } catch (e) {
      print(e.message);
      final snackBar = new SnackBar(
        content: new Text("There was an error logging into the app"),
        duration: new Duration(seconds: 2),
        backgroundColor: Colors.blue,
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  Future<void> _handleRegister(context) async {
    String _passConfirm;
    showModalBottomSheet(context: context, builder: (context) {
      return Container(
        color: Color(0xFF737373),
        height: 200,
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Please confirm your password below:",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
              ),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
                onChanged: (String str) {
                  _passConfirm = str;
                  //print(_passConfirm);
                },
              ),
              RaisedButton(
                color: Colors.teal,
                textColor: Colors.white,
                onPressed: () async {
                  print(_passConfirm);
                  if(_password==_passConfirm){
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailAddress, password: _password);
                    Navigator.pop(context);
                    onLogIn();
                  } else {
                    final snackBar = new SnackBar(
                      content: new Text("Passwords must match"),
                      duration: new Duration(seconds: 2),
                      backgroundColor: Colors.blue,
                    );
                    _scaffoldKey.currentState.showSnackBar(snackBar);
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text('Confirm', style: TextStyle(fontSize: 20)),
              )
            ],
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              )
          ),
        ),
      );
    });
  }

  void onLogIn() async {
    //FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).set({});
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid.toString())
        .collection("favorites")
        .get();
    List<QueryDocumentSnapshot> favs = snapshot.docs;
    //assert(favs.isNotEmpty);
    //print(favs.runtimeType.toString());
    //print(favs.toString());

    var storedSuggestions = favs.map((e) => WordPair(
        e.data().entries.first.value.toString(),
        e.data().entries.last.value.toString()));
    widget.stored.addAll(storedSuggestions.toSet());
    widget.isLoggedIn = true;
    Navigator.pop(context, widget.isLoggedIn);
  }
}

class StoredScreen extends StatefulWidget {
  final Set<WordPair> stored;

  StoredScreen(this.stored);

  @override
  _StoredScreenState createState() => _StoredScreenState(stored);
}

class _StoredScreenState extends State<StoredScreen> {
  final Set<WordPair> stored;
  final TextStyle _biggerFont = const TextStyle(fontSize: 18);

  _StoredScreenState(this.stored);

  @override
  Widget build(BuildContext context) {
    final tiles = stored.map(
      (WordPair pair) {
        return ListTile(
          title: Text(
            pair.asPascalCase,
            style: _biggerFont,
          ),
          trailing: IconButton(
              icon: Icon(Icons.delete), onPressed: () => _handleDelete(pair)),
        );
      },
    );
    final divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Suggestions'),
      ),
      body: ListView(children: divided),
    );
  }

  _handleDelete(WordPair pair) {
    setState(() {
      stored.remove(pair);
    });
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //final wordPair = WordPair.random();
    /*return MaterialApp(
      title: 'Is this Flutter?',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Hello Naseem!!!!'),
        ),
        body: Center(
          //child: const Text('Hello World'),
          //child: Text(wordPair.asPascalCase),
          child: RandomWords(),
        ),
      ),
    );*/
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        primaryColor: Colors.red,
      ),
      home: RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  bool _isLogged = false;
  static String currAddress = "SEQ_DUMMY";
  final List<WordPair> _suggestions = <WordPair>[];
  final _stored = Set<WordPair>();
  final TextStyle _biggerFont = const TextStyle(fontSize: 18);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _otherKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    //final wordPair = WordPair.random();
    //return Text(wordPair.asPascalCase);

    Widget mainScreenWidget = Scaffold(
      // Add from here...
      appBar: AppBar(
        title: Text('Startup Name Generator'),
        actions: [
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
          IconButton(
              icon: Icon(_isLogged ? Icons.exit_to_app : Icons.login),
              onPressed: _isLogged ? _logOut : _pushLogin),
        ],
      ),
      body: _buildSuggestions(),
    );
    Widget profileSection = Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            child: Text("placeholder"),
            backgroundColor: Colors.orange,
            radius: 50,
          ),
          Column(
            children: [
              Text(
                currAddress
              ),
              RaisedButton(
                child: Text("Change avatar"),
                textColor: Colors.white,
                onPressed: () async {
                  File img = await ImagePicker.pickImage(source: ImageSource.gallery);
                },
              )
            ],
          )
        ],
      ),
    );

    if(_isLogged){
      return Scaffold(
        body: SnappingSheet(
          sheetAbove: SnappingSheetContent(
              child: mainScreenWidget,
              heightBehavior: SnappingSheetHeight.fit()
          ),
          sheetBelow: SnappingSheetContent(
            child: profileSection,
            heightBehavior: SnappingSheetHeight.fit()
          ),
          grabbing: ListTile(
            title: FittedBox(
              child: Text(
                "Welcome back, " + currAddress,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
              ),
              fit: BoxFit.fitWidth,
            ),
            trailing: Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white,),
            tileColor: Colors.teal,
          ),
          grabbingHeight: 55,
          snapPositions: [SnapPosition(
                positionFactor: 0,
                snappingCurve: Curves.decelerate,
                snappingDuration: Duration(milliseconds: 100)
            ), SnapPosition(
                positionFactor: 0.2,
                snappingCurve: Curves.decelerate,
                snappingDuration: Duration(milliseconds: 200)
            )],
        ),
      );
    } else {
      return mainScreenWidget;
    }
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        // The itemBuilder callback is called once per suggested
        // word pairing, and places each suggestion into a ListTile
        // row. For even rows, the function adds a ListTile row for
        // the word pairing. For odd rows, the function adds a
        // Divider widget to visually separate the entries. Note that
        // the divider may be difficult to see on smaller devices.
        itemBuilder: (BuildContext _context, int i) {
          // Add a one-pixel-high divider widget before each row
          // in the ListView.
          if (i.isOdd) {
            return Divider();
          }

          // The syntax "i ~/ 2" divides i by 2 and returns an
          // integer result.
          // For example: 1, 2, 3, 4, 5 becomes 0, 1, 1, 2, 2.
          // This calculates the actual number of word pairings
          // in the ListView,minus the divider widgets.
          final int index = i ~/ 2;
          // If you've reached the end of the available word
          // pairings...
          if (index >= _suggestions.length) {
            // ...then generate 10 more and add them to the
            // suggestions list.
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index]);
        });
  }

  Widget _buildRow(WordPair pair) {
    final alreadySaved = _stored.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        // NEW from here...
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _stored.remove(pair);
          } else {
            _stored.add(pair);
          }
        });
      },
    );
  }

  void _pushSaved() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return StoredScreen(_stored);
    }));
    setState(() {});
  }

  void _logOut() async {
    //List<Map<String,String>> myFavorites = _stored.map((e) => {"first" : e.first, "second" : e.second}).toList();
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid.toString())
        .collection("favorites")
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });

    // await.delete();
    _stored.forEach((e) async {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser.uid.toString())
          .collection("favorites")
          .doc(e.toString())
          .set({"first": e.first, "second": e.second});
    });

    //print(myFavorites.runtimeType.toString());
    //print(myFavorites.toString());
    await FirebaseAuth.instance.signOut();
    setState(() {
      _stored.clear();
      _isLogged = false;
    });
  }

  void _pushLogin() async {
    _isLogged = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return LoginScreen(_isLogged, _stored);
        },
      ),
    );
    setState(() {});
  }

  /*Future<void> _uploadImage(String email) async {
    final File _myImage = await PickMyImage.getImage();
    if(_myImage!=null){
      final StorageReference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child("user/$email/i"); //i is the name of the image
      StorageUploadTask uploadTask =
      firebaseStorageRef.putFile(_myImage);
      StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
      var downloadUrl = await storageSnapshot.ref.getDownloadURL();
      if (uploadTask.isComplete) {
        final String url = downloadUrl.toString();
        print(url);
        //You might want to set this as the _auth.currentUser().photourl
      } else {
        //error uploading
      }
    }
  }*/

}
