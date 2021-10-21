import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wits_overflow/utils/functions.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';

import 'package:cloud_firestore/cloud_firestore.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Comments extends StatefulWidget {
  /// just displays a list of comments

  final List<Map<String, dynamic>> comments;
  final Map<String, Map<String, dynamic>> commentsAuthors;
  final onAddComments;

  Comments(
      {required this.comments,
      required this.commentsAuthors,
      required this.onAddComments,
      auth,
      firestore});

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  List<Widget> listComments = <Widget>[];
  late TextButton button;

  void initState() {
    super.initState();
    // add comments to a list of comments
    int numComments = this.widget.comments.length;
    numComments = numComments > 5 ? 5 : numComments;
    for (var i = 0; i < numComments; i++) {
      Map<String, dynamic> comment = this.widget.comments[i];
      this.listComments.add(Comment(
            body: comment['body'],
            commentedAt: comment['commentedAt'] as Timestamp,
            displayName:
                this.widget.commentsAuthors[comment['id']]!['displayName'],
            imageURL: comment['image_url'],
          ));
      this.listComments.add(Divider(
            height: 8,
          ));
    }

    // building show more comments / Add a comment button
    late Text text;
    late var onPressedCallback;
    if (this.widget.comments.length > 5) {
      text = Text(
        'Show ${this.widget.comments.length - 5} more comments',
        style: TextStyle(
          color: Colors.blue,
        ),
      );
      onPressedCallback = this._showMoreComments;
    } else {
      text = Text(
        'Add a comment',
        style: TextStyle(
          color: Colors.blue,
        ),
      );
      onPressedCallback = this.widget.onAddComments;
    }

    this.button = TextButton(
      onPressed: onPressedCallback,
      child: text,
    );

    this.listComments.add(
          Container(
            color: Color.fromRGBO(0, 0, 0, 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: this.button,
                )
              ],
            ),
          ),
        );
  }

  void _showMoreComments() {
    setState(() {
      this.listComments = [];
      for (var i = 0; i < this.widget.comments.length; i++) {
        Map<String, dynamic> comment = this.widget.comments[i];
        this.listComments.add(Comment(
              body: comment['body'],
              commentedAt: comment['commentedAt'] as Timestamp,
              displayName:
                  this.widget.commentsAuthors[comment['id']]!['displayName'],
            ));
        this.listComments.add(Divider(
              height: 8,
            ));
      }

      this.button = TextButton(
        child: Text('Add a comment'),
        onPressed: this.widget.onAddComments,
      );
      this.listComments.add(
            Container(
              color: Color.fromRGBO(100, 0, 0, 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  this.button,
                ],
              ),
            ),
          );
    });
  }

  @override
  build(BuildContext buildContext) {
    return Container(
      padding: EdgeInsets.fromLTRB(70, 0, 50, 0),
      child: Column(
        children: listComments,
      ),
    );
  }
}

class Comment extends StatefulWidget {
  final String displayName;
  final String body;
  final Timestamp commentedAt;
  final String? imageURL;

  late final WitsOverflowData witsOverflowData = WitsOverflowData();
  late final _firestore;
  late final _auth;

  Comment({
    required this.displayName,
    required this.body,
    required this.commentedAt,
    firestore,
    auth,
    this.imageURL,
  }) {
    this._firestore =
        firestore == null ? FirebaseFirestore.instance : firestore;
    this._auth = auth == null ? FirebaseAuth.instance : auth;
    this
        .witsOverflowData
        .initialize(firestore: this._firestore, auth: this._auth);
  }

  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  bool isBusy = true;
  Widget? questionImage;

  Future<void> getImage() async {
    if (this.widget.imageURL != null) {
      try {
        Uint8List? uint8list = await firebase_storage.FirebaseStorage.instance
            .ref(this.widget.imageURL)
            .getData();
        if (uint8list != null) {
          this.questionImage = Image.memory(uint8list);
          print(this.questionImage);
        } else {
          print('[uint8list IS NULL]');
        }
      } on firebase_core.FirebaseException catch (e) {
        print('[FAILED TO FETCH QUESTION IMAGE, ERROR -> $e]');
      }
    }

    setState(() {
      this.isBusy = false;
    });
  }

  void initState() {
    super.initState();
    this
        .widget
        .witsOverflowData
        .initialize(firestore: this.widget._firestore, auth: this.widget._auth);
    getImage();
    print("Question Image: $questionImage");
  }

  @override
  Widget build(BuildContext context) {
    if (this.isBusy) {
      Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                child: RichText(
                  text: TextSpan(
                    text: this.widget.body + ' - ',
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(
                        text: this.widget.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                      TextSpan(
                        text: ' ' +
                            formatDateTime(this.widget.commentedAt.toDate()),
                      ),
                    ],
                  ),
                ),
              )),
          this.questionImage == null
              ? Padding(padding: EdgeInsets.all(0))
              : Container(height: 20, width: 20, child: this.questionImage),
          this.questionImage == null
              ? Padding(padding: EdgeInsets.all(0))
              : Center(
                  child: new RichText(
                    text: new TextSpan(
                      children: [
                        new TextSpan(
                          text: 'Click To Download Image',
                          style:
                              new TextStyle(color: Colors.blue, fontSize: 20),
                          recognizer: new TapGestureRecognizer()
                            ..onTap = () {
                              launch(this.widget.imageURL!);
                            },
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
