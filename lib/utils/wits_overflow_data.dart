import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WitsOverflowData {
  late CollectionReference<Map<String, dynamic>> questions;
  late CollectionReference<Map<String, dynamic>> courses;
  late CollectionReference<Map<String, dynamic>> modules;
  late CollectionReference<Map<String, dynamic>> favourites;

  WitsOverflowData._internal() {
    questions = FirebaseFirestore.instance.collection('questions-2');
    courses = FirebaseFirestore.instance.collection('courses-2');
    modules = FirebaseFirestore.instance.collection('modules-2');
    favourites = FirebaseFirestore.instance.collection('favourites-2');
  }

  //
  // METHODS

  Future<Map<String, dynamic>?> fetchQuestion(String questionId) async {
    Map<String, dynamic>? result;

    await questions.doc(questionId).get().then((snapshot) {
      if (snapshot.exists) {
        result = snapshot.data();
        result!['id'] = snapshot.id;
      }
    });

    return result;
  }

  Future<int> fetchQuestionVoteCount(String questionId) async {
    return await FirebaseFirestore.instance
        .collection('questions-2')
        .doc(questionId)
        .collection('votes')
        .get()
        .then((snapshot) {
      return snapshot.size;
    });
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
        var fq = doc['favouriteQuestions'];
        for (int i = 0; i < fq.length; i++) {
          var questionId = fq[i];
          //print(questionId);

          await fetchQuestion(questionId).then((question) {
            //print(question);
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
        'authorId': FirebaseAuth.instance.currentUser!.uid
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
        'authorId': FirebaseAuth.instance.currentUser!.uid
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
        'authorId': FirebaseAuth.instance.currentUser!.uid
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
        'authorId': FirebaseAuth.instance.currentUser!.uid
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
        'authorId': FirebaseAuth.instance.currentUser!.uid
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
        'authorId': FirebaseAuth.instance.currentUser!.uid
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
        'authorId': FirebaseAuth.instance.currentUser!.uid
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
        'authorId': FirebaseAuth.instance.currentUser!.uid
      });
    });
  }

  // Singleton stuff
  static final WitsOverflowData _singleton = WitsOverflowData._internal();
  factory WitsOverflowData() => _singleton;
}
