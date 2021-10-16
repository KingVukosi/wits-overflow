import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wits_overflow/utils/functions.dart';
import 'BuildImage.dart';

class Comments extends StatefulWidget {
  /// just displays a list of comments

  final List<Map<String, dynamic>> comments;
  final Map<String, Map<String, dynamic>> commentsAuthors;
  final onAddComments;

  Comments({
    required this.comments,
    required this.commentsAuthors,
    required this.onAddComments,
  });

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
            image: comment['image'],
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
              image: comment['image'],
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

class Comment extends StatelessWidget {
  final String displayName;
  final String body;
  final Timestamp commentedAt;
  final String image;

  Comment(
      {required this.displayName,
      required this.body,
      required this.commentedAt,
      required this.image});

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
    return Container(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              child: RichText(
                  text: TextSpan(
                text: this.body + ' - ',
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                    text: this.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                ],
              )),
            ),
          ),
          ImageBuilder(
            imageFile: image,
            question: false,
          )
        ],
      ),
    );
  }
}
