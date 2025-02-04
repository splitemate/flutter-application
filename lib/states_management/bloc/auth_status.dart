abstract class AppSubmissionStatus {
  const AppSubmissionStatus();
}

class InitialStatus extends AppSubmissionStatus {
  const InitialStatus();
}

class FormSubmitting extends AppSubmissionStatus {}

class SubmissionSuccess extends AppSubmissionStatus {
  const SubmissionSuccess();
}

class SubmissionFailed extends AppSubmissionStatus {
  final Object exception;

  SubmissionFailed(this.exception);
}

class OtpRequestedState extends AppSubmissionStatus {}

class OtpSentSuccess extends AppSubmissionStatus {}

class OtpSentFailed extends AppSubmissionStatus {
  final Object exception;

  OtpSentFailed(this.exception);
}

class OAuthSubmitted extends AppSubmissionStatus {}

class OAuthRequestSuccess extends AppSubmissionStatus {}

class OAuthRequestFailed extends AppSubmissionStatus {}
