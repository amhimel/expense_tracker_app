class PhoneAuthModel {
  String phoneNumber = '';
  String verificationId = '';
  String smsCode = '';
  bool isAuthenticated = false;
  bool isLoading = false;
  bool isVerificationInProgress = false;

  PhoneAuthModel({
    this.phoneNumber = '',
    this.verificationId = '',
    this.smsCode = '',
    this.isAuthenticated = false,
    this.isLoading = false,
    this.isVerificationInProgress = false,
  });

  // Reset all fields
  void reset() {
    phoneNumber = '';
    verificationId = '';
    smsCode = '';
    isAuthenticated = false;
    isLoading = false;
    isVerificationInProgress = false;
  }

  // Update authentication status
  void updateAuthStatus(bool status) {
    isAuthenticated = status;
  }

  // Update loading state
  void updateLoadingState(bool status) {
    isLoading = status;
  }

  // Update verification state
  void updateVerificationInProgress(bool status) {
    isVerificationInProgress = status;
  }

  // Update verificationId
  void updateVerificationId(String id) {
    verificationId = id;
  }

  // Update SMS code
  void updateSmsCode(String code) {
    smsCode = code;
  }

  // Update phone number
  void updatePhoneNumber(String number) {
    phoneNumber = number;
  }
}
