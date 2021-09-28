import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wits_overflow/utils/functions.dart';

/// before any class methods can be called, you have to
/// call the initialize method first
class WitsOverflowData {
  late var firestore;
  late var auth;

  late CollectionReference<Map<String, dynamic>> questions;
  late CollectionReference<Map<String, dynamic>> courses;
  late CollectionReference<Map<String, dynamic>> modules;
  late CollectionReference<Map<String, dynamic>> favourites;
  late CollectionReference<Map<String, dynamic>> users;

  // Singleton stuff
  static final WitsOverflowData _singleton = WitsOverflowData._internal();
  factory WitsOverflowData() => _singleton;
  WitsOverflowData._internal();

  void initialize({firestore, auth}) {
    this.firestore = firestore == null ? FirebaseFirestore.instance : firestore;
    this.auth = auth == null ? FirebaseAuth.instance : auth;

    this.questions = this.firestore.collection('questions-2');
    this.courses = this.firestore.collection('courses-2');
    this.modules = this.firestore.collection('modules-2');
    this.favourites = this.firestore.collection('favourites-2');
    this.users = this.firestore.collection('users');
  }

  Future<List<Map<String, dynamic>>> fetchUserAnswers(
      {required String userId}) async {
    List<Map<String, dynamic>> userAnswers = [];
    this.questions.get().then((questions) async {
      for (int i = 0; i < questions.docs.length; i++) {
        await questions.docs[i].reference
            .collection('answers')
            .where('authorId', isEqualTo: userId)
            .get()
            .then((answers) {
          for (int j = 0; j < answers.docs.length; j++) {
            Map<String, dynamic> answer = answers.docs[i].data();
            answer.addAll({'id': answers.docs[i].id});
            userAnswers.add(answer);
          }
        });
      }
    });
    return userAnswers;
  }

  User? getCurrentUser() {
    return this.auth.currentUser;
  }

  /// fetch
  Future<List<Map<String, dynamic>>?> fetchQuestionAnswerVotes(
      String questionId, String answerId) async {
    List<Map<String, dynamic>> questionAnswerVotes = [];
    await questions
        .doc(questionId)
        .collection('answers')
        .doc(answerId)
        .collection('votes')
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> value) {
      for (var i = 0; i < value.docs.length; i++) {
        Map<String, dynamic> questionAnswerVote = value.docs[i].data();
        questionAnswerVote['id'] = value.docs[i].id;
        questionAnswerVotes.add(questionAnswerVote);
      }
    });
    return questionAnswerVotes;
  }

  Future<List<Map<String, dynamic>>?> fetchQuestionAnswers(
      String questionId) async {
    List<Map<String, dynamic>> questionAnswers = [];
    await questions
        .doc(questionId)
        .collection('answers')
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> value) {
      for (var i = 0; i < value.docs.length; i++) {
        Map<String, dynamic> questionAnswer = value.docs[i].data();
        questionAnswer['id'] = value.docs[i].id;
        questionAnswers.add(questionAnswer);
      }
    });
    return questionAnswers;
  }

  Future<List<Map<String, dynamic>>?> fetchQuestionComments(
      String questionId) async {
    List<Map<String, dynamic>> questionComments = [];

    await questions
        .doc(questionId)
        .collection('comments')
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> value) {
      for (var i = 0; i < value.docs.length; i++) {
        Map<String, dynamic> questionComment = value.docs[i].data();
        questionComment['id'] = value.docs[i].id;
        questionComments.add(questionComment);
      }
    });
    return questionComments;
  }

  Future<List<Map<String, dynamic>>?> fetchQuestionAnswerComments(
      {required String questionId, required String answerId}) async {
    List<Map<String, dynamic>> questionComments = [];

    await questions
        .doc(questionId)
        .collection('answers')
        .doc(answerId)
        .collection('comments')
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> value) {
      for (var i = 0; i < value.docs.length; i++) {
        Map<String, dynamic> questionComment = value.docs[i].data();
        questionComment['id'] = value.docs[i].id;
        questionComments.add(questionComment);
      }
    });
    return questionComments;
  }

  Future<List<Map<String, dynamic>>?> fetchQuestionVotes(
      String questionId) async {
    List<Map<String, dynamic>> questionVotes = [];
    await questions
        .doc(questionId)
        .collection('votes')
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> value) {
      for (var i = 0; i < value.docs.length; i++) {
        questionVotes.add(value.docs[i].data());
      }
    });
    return questionVotes;
  }

  Future<Map<String, dynamic>?> fetchUserInformation(String userId) async {
    Map<String, dynamic>? userInfo;
    await this
        .users
        .doc(userId)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> value) {
      userInfo = value.data();
      userInfo?.addAll({'id': value.id});
    });

    return userInfo;
  }

  Future<Map<String, dynamic>?> fetchQuestion(String questionId) async {
    Map<String, dynamic>? question;

    await questions.doc(questionId).get().then((value) {
      question = value.data();
      question?.addAll({'id': value.id});
    });

    return question;
  }

  Future<List<Map<String, dynamic>>> fetchQuestions() async {
    List<Map<String, dynamic>> results = List.empty(growable: true);

    await questions.get().then((snapshot) => {
          snapshot.docs.forEach((doc) {
            Map<String, dynamic> data = doc.data();
            data['id'] = doc.id;
            results.add(data);
          })
        });

    return results;
  }

  Future<List<Map<String, dynamic>>> fetchUserQuestions(
      {required String userId}) async {
    List<Map<String, dynamic>> results = List.empty(growable: true);

    await questions
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get()
        .then((snapshot) => {
              snapshot.docs.forEach((doc) {
                Map<String, dynamic> data = doc.data();
                data['id'] = doc.id;
                results.add(data);
              })
            });

    return results;
  }

  Future<List<Map<String, dynamic>>> fetchModuleQuestions(
      {required String moduleId}) async {
    List<Map<String, dynamic>> results = List.empty(growable: true);

    await questions
        .where('moduleId', isEqualTo: moduleId)
        .orderBy('createdAt', descending: true)
        .get()
        .then((snapshot) => {
              snapshot.docs.forEach((doc) {
                Map<String, dynamic> data = doc.data();
                data['id'] = doc.id;
                results.add(data);
              })
            });

    return results;
  }

  Future<List<Map<String, dynamic>>> fetchLatestQuestions(int limit) async {
    List<Map<String, dynamic>> results = List.empty(growable: true);

    await questions
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get()
        .then((snapshot) => {
              snapshot.docs.forEach((doc) {
                Map<String, dynamic> data = doc.data();
                data['id'] = doc.id;
                results.add(data);
              })
            });

    return results;
  }

  Future<List<Map<String, dynamic>>> fetchCourses() async {
    List<Map<String, dynamic>> results = List.empty(growable: true);

    await courses.get().then((snapshot) => {
          snapshot.docs.forEach((doc) {
            Map<String, dynamic> data = doc.data();
            data['id'] = doc.id;
            results.add(data);
          })
        });

    return results;
  }

  Future<List<Map<String, dynamic>>> fetchModules([String? courseId]) async {
    List<Map<String, dynamic>> results = List.empty(growable: true);

    Query<Map<String, dynamic>> ref = modules;

    if (courseId != null && courseId != "") {
      ref = ref.where("courseId", isEqualTo: courseId);
    }

    await ref.get().then((snapshot) => {
          snapshot.docs.forEach((doc) {
            Map<String, dynamic> data = doc.data();
            data['id'] = doc.id;
            results.add(data);
          })
        });

    return results;
  }

  Future<List<Map<String, dynamic>>> fetchUserFavouriteQuestions(
      {required String userId}) async {
    List<Map<String, dynamic>> results = List.empty(growable: true);

    await favourites.doc(userId).get().then((doc) async {
      if (doc.exists) {
        var fq = doc.get('favouriteQuestions');
        for (int i = 0; i < fq.length; i++) {
          await fetchQuestion(fq[i]).then((question) {
            if (question != null) {
              results.add(question);
            }
          });
        }
      }
    });

    return results;
  }

  Future<DocumentReference<Map<String, dynamic>>> addQuestion(
      Map<String, dynamic> data) async {
    return questions.add(data);
  }

  Future<void> addFavouriteQuestion(
      {required String userId, required String questionId}) async {
    await favourites.doc(userId).get().then((doc) {
      if (doc.exists) {
        var fq = doc['favouriteQuestions'];
        for (int i = 0; i < fq.length; i++) {
          if (fq[i] == questionId) {
            return;
          }
        }

        fq.add(questionId);

        favourites.doc(userId).set({'favouriteQuestions': fq},
            SetOptions(mergeFields: ['favouriteQuestions'])).then((result) {
          return;
        });
      } else {
        favourites.doc(userId).set({
          'favouriteQuestions': [questionId]
        }).then((result) {
          return;
        });
      }
    });
  }

  void voteQuestion(
      {required context,
      required int value,
      required questionId,
      required userId}) async {
    /// handler function when a user votes on a question

    Map<String, dynamic> data = {
      'value': value,
      'user': userId,
      'votedAt': DateTime.now(),
    };

    CollectionReference<Map<String, dynamic>> questionVotesCollection =
        this.questions.doc(questionId).collection('votes');
    QuerySnapshot<Map<String, dynamic>> questionUserVote =
        await questionVotesCollection.where('user', isEqualTo: userId).get();

    if (questionUserVote.docs.isEmpty) {
      questionVotesCollection.add(data).then((value) {
        showNotification(context, "Vote added");
      }).catchError((error) {
        showNotification(context, 'Error occurred');
      });
    } else {
      showNotification(context, 'Already voted');
    }
  }

  Future voteAnswer(
      {required context,
      required String questionId,
      required String answerId,
      required int value,
      required String userId}) async {
    // check if user has already voted on this answer
    DocumentSnapshot<Map<String, dynamic>> answer = await this
        .questions
        .doc(questionId)
        .collection('answers')
        .doc(answerId)
        .get();
    CollectionReference<Map<String, dynamic>> answerVotesReference =
        answer.reference.collection('votes');
    QuerySnapshot<Map<String, dynamic>> userVote = await answerVotesReference
        .where('user', isEqualTo: userId)
        .limit(1)
        .get();

    if (userVote.docs.isEmpty) {
      // then the user can vote
      Map<String, dynamic> data = {
        'votedAt': DateTime.now(),
        'user': userId,
        'value': value,
      };

      answerVotesReference.add(data).then((value) {
        // show that the vote was successful
        showNotification(context, "Vote added");
      }).catchError((error) {
        showNotification(context, "Error occurred");
      });
    } else {
      showNotification(context, 'Already voted');
    }
  }

  Future<Map<String, dynamic>?> postQuestionComment(
      {required String questionId,
      required String body,
      required String authorId,
      DateTime? commentedAt}) async {
    Map<String, dynamic>? comment;
    Map<String, dynamic> data = {
      'body': body,
      'authorId': authorId,
      'commentedAt': commentedAt == null ? DateTime.now() : commentedAt,
    };
    await this
        .questions
        .doc(questionId)
        .collection('comments')
        .add(data)
        .then((value) {
      comment = data;
      comment?.addAll({'id': value.id});
    });
    return comment;
  }

  Future<Map<String, dynamic>?> postQuestionAnswerComment(
      {required String questionId,
      required String answerId,
      required String body,
      required String authorId,
      DateTime? commentedAt}) async {
    Map<String, dynamic>? comment;
    Map<String, dynamic> data = {
      'body': body,
      'authorId': authorId,
      'commentedAt': commentedAt == null ? DateTime.now() : commentedAt,
    };
    await this
        .questions
        .doc(questionId)
        .collection('answers')
        .doc(answerId)
        .collection('comments')
        .add(data)
        .then((value) {
      comment = data;
      comment?.addAll({'id': value.id});
    });
    return comment;
  }

  Future<Map<String, dynamic>?> postAnswer(
      {required String questionId,
      required String authorId,
      required String body,
      DateTime? answeredAt}) async {
    // TODO: check id user has already voted, if yes, then throw error
    Map<String, dynamic>? answer;
    await this
        .questions
        .doc(questionId)
        .collection('answers')
        .add({'authorId': authorId, 'body': body}).then((value) {
      answer = {
        'id': value.id,
        'body': body,
        'authorId': authorId,
        'answeredAt': answeredAt == null ? DateTime.now() : answeredAt,
      };
    });
    return answer;
  }

  Future<Map<String, dynamic>?> editAnswer(
      {required String questionId,
      required String answerId,
      required String editorId,
      required body,
      DateTime? editedAt}) async {
    Map<String, dynamic> data = {
      'body': body,
      'editorId': editorId,
      'editedAt': editedAt == null ? DateTime.now() : editedAt,
    };
    await this
        .questions
        .doc(questionId)
        .collection('answers')
        .doc(answerId)
        .update(data);
    Map<String, dynamic>? answer =
        await this.fetchAnswer(questionId: questionId, answerId: answerId);
    return answer;
  }

  Future<Map<String, dynamic>?> fetchAnswer(
      {required String questionId, required String answerId}) async {
    Map<String, dynamic>? answer;
    await this
        .questions
        .doc(questionId)
        .collection('answers')
        .doc(answerId)
        .get()
        .then((value) {
      answer = value.data();
      answer?.addAll({'id': value.id});
    });
    return answer;
  }

  Future<void> seedDatabase() async {
    String? courseId;

    await courses.add({'code': 'COMS', 'name': 'Computer Science'}).then((doc) {
      courseId = doc.id;
    });

    await modules.add({
      'courseId': courseId,
      'code': 'COMS3009',
      'name': 'Software Design'
    }).then((doc) {
      questions.add({
        'courseId': courseId,
        'moduleId': doc.id,
        'createdAt': DateTime.now(),
        'title': 'Software Design vs. Software Architecture?',
        'body':
            'Could someone explain the difference between Software Design and Software Architecture?',
        'tags': ['COMS', 'COMS3007'],
        'authorId': this.getCurrentUser()!.uid
      });
    });
    await modules.add({
      'courseId': courseId,
      'code': 'COMS3007',
      'name': 'Machine Learning'
    }).then((doc) {
      questions.add({
        'courseId': courseId,
        'moduleId': doc.id,
        'createdAt': DateTime.now(),
        'title':
            'What is the difference between supervised learning and unsupervised learning?',
        'body':
            'In terms of artificial intelligence and machine learning, what is the difference between supervised and unsupervised learning? Can you provide a basic, easy explanation with an example?',
        'tags': ['COMS', 'COMS3009'],
        'authorId': this.getCurrentUser()!.uid
      });
    });
    await modules.add({
      'courseId': courseId,
      'code': 'COMS3006',
      'name': 'Computer Graphics and Visualization'
    }).then((doc) {
      questions.add({
        'courseId': courseId,
        'moduleId': doc.id,
        'createdAt': DateTime.now(),
        'title':
            'How to make graphics with transparent background in R using ggplot2?',
        'body':
            'I need to output ggplot2 graphics from R to PNG files with transparent background. Everything is ok with basic R graphics, but no transparency with ggplot2',
        'tags': ['COMS', 'COMS3006'],
        'authorId': this.getCurrentUser()!.uid
      });
    });
    await modules.add({
      'courseId': courseId,
      'code': 'COMS3003',
      'name': 'Formal Languages and Automata'
    }).then((doc) {
      questions.add({
        'courseId': courseId,
        'moduleId': doc.id,
        'createdAt': DateTime.now(),
        'title':
            'Generating grammars from a language (formal languages and automata theory)',
        'body':
            'guys I\'ve been working on this assignment for my formal languages class for a couple of days now, and I\'m stuck when it comes to generating grammars for a given language. I don\'t have an example in my textbook similar to this question to follow, so I was hoping anyone could provide an explanation. thank you.',
        'tags': ['COMS', 'COMS3003'],
        'authorId': this.getCurrentUser()!.uid
      });
    });

    await courses.add({'code': 'MATH', 'name': 'Mathematics'}).then((doc) {
      courseId = doc.id;
    });

    await modules.add({
      'courseId': courseId,
      'code': 'MATH2007',
      'name': 'Multivariable Calculus'
    }).then((doc) {
      questions.add({
        'courseId': courseId,
        'moduleId': doc.id,
        'createdAt': DateTime.now(),
        'title':
            'How does the back-propagation algorithm deal with non-differentiable activation functions?',
        'body':
            'While digging through the topic of neural networks and how to efficiently train them, I came across the method of using very simple activation functions, such as the rectified linear unit (ReLU), instead of the classic smooth sigmoids. The ReLU-function is not differentiable at the origin, so according to my understanding the backpropagation algorithm (BPA) is not suitable for training a neural network with ReLUs, since the chain rule of multivariable calculus refers to smooth functions only. However, none of the papers about using ReLUs that I read address this issue. ReLUs seem to be very effective and seem to be used virtually everywhere while not causing any unexpected behavior. Can somebody explain to me why ReLUs can be trained at all via the backpropagation algorithm?',
        'tags': ['MATH', 'MATH2007'],
        'authorId': this.getCurrentUser()!.uid
      });
    });
    await modules.add({
      'courseId': courseId,
      'code': 'MATH2019',
      'name': 'Linear Algebra'
    }).then((doc) {
      questions.add({
        'courseId': courseId,
        'moduleId': doc.id,
        'createdAt': DateTime.now(),
        'title':
            'What are the most widely used C++ vector/matrix math/linear algebra libraries, and their cost and benefit tradeoffs?',
        'body':
            'It seems that many projects slowly come upon a need to do matrix math, and fall into the trap of first building some vector classes and slowly adding in functionality until they get caught building a half-assed custom linear algebra library, and depending on it. I\'d like to avoid that while not building in a dependence on some tangentially related library (e.g. OpenCV, OpenSceneGraph).',
        'tags': ['MATH', 'MATH2019'],
        'authorId': this.getCurrentUser()!.uid
      });
    });
    await modules.add({
      'courseId': courseId,
      'code': 'MATH2025',
      'name': 'Transition to Abstract Maths'
    }).then((doc) {
      questions.add({
        'courseId': courseId,
        'moduleId': doc.id,
        'createdAt': DateTime.now(),
        'title':
            'Loop through an array and return the values sorted by a grouping pattern',
        'body':
            'I\'m trying to loop through an array and return the values sorted by a pattern (groups of two). My abstract math skills are failing me. I\'m stumped, I can\'t figure out the pattern. Here\'s what I have so far.',
        'tags': ['MATH', 'MATH2025'],
        'authorId': this.getCurrentUser()!.uid
      });
    });
    await modules.add({
      'courseId': courseId,
      'code': 'MATH2001',
      'name': 'Basic Analysis'
    }).then((doc) {
      questions.add({
        'courseId': courseId,
        'moduleId': doc.id,
        'createdAt': DateTime.now(),
        'title':
            'Is there some module/function in NLTK/SKLearn which will do basic analysis of the text data?',
        'body':
            'I have multiple text files such that each line has exactly one document. I want to do a basic analysis on the text and answer questions like.',
        'tags': ['MATH', 'MATH2001'],
        'authorId': this.getCurrentUser()!.uid
      });
    });
  }
}
