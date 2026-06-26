// Parameter objects for the auth use cases.

class SignInParams {
  const SignInParams({required this.email, required this.password});
  final String email;
  final String password;
}

class SignUpParams {
  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
    required this.mobileNumber,
    required this.barangay,
    required this.address,
    required this.dpaConsent,
  });

  final String email;
  final String password;
  final String name;
  final String mobileNumber;
  final String barangay;
  final String address;
  final bool dpaConsent;
}

class VerifyOtpParams {
  const VerifyOtpParams({required this.email, required this.otp});
  final String email;
  final String otp;
}

class EmailParams {
  const EmailParams({required this.email});
  final String email;
}
