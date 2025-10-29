class Validator {
  /// ✅ Kiểm tra tên người dùng (chỉ cho phép chữ cái, không chứa số hoặc ký tự đặc biệt)
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tên người dùng không được để trống';
    }
    final regex = RegExp(r'^[a-zA-ZÀ-ỹ\s]+$');
    if (!regex.hasMatch(value.trim())) {
      return 'Tên người dùng không hợp lệ';
    }
    return null;
  }

  /// ✅ Kiểm tra email hợp lệ (phải có dạng @example.com)
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email không được để trống';
    }
    final regex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );
    if (!regex.hasMatch(value.trim())) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  /// ✅ Kiểm tra mật khẩu (không được để trống)
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mật khẩu không được để trống';
    }
    return null;
  }
}
