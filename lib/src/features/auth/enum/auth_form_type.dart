enum AuthFormType {
  signIn,
  signUp,
  forgotPassword;

  bool get isSignIn => this == AuthFormType.signIn;
  bool get isSignUp => this == AuthFormType.signUp;
  bool get isForgotPassword => this == AuthFormType.forgotPassword;
}
