/// exception class to throw when a user wants to post an answer but already
/// has a answer for that question
class UseQuestionAnswerExist implements Exception {
  String cause;
  UseQuestionAnswerExist(this.cause);
}
