import 'package:ecommerce_app/data/local_storage.dart';
import 'package:ecommerce_app/data/user_model.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;

  // Called at app start: restore the saved login
  void loadSession() {
    final email = LocalStorage.sessionEmail;
    if (email != null) _user = LocalStorage.findUser(email);
  }

  Future<String?> register(String name, String email, String password) async {
    final key = email.trim().toLowerCase();
    if (LocalStorage.findUser(key) != null) {
      return 'This email is already registered';
    }
    final newUser = UserModel(
      id: const Uuid().v4(),
      name: name.trim(),
      email: key,
      password: password,
    );
    await LocalStorage.saveUser(newUser);
    await LocalStorage.setSession(key);
    _user = newUser;
    notifyListeners();
    return null;
  }

  Future<String?> login(String email, String password) async {
    final key = email.trim().toLowerCase();
    final found = LocalStorage.findUser(key);
    if (found == null) return 'No account found for this email';
    if (found.password != password) return 'Incorrect password';
    await LocalStorage.setSession(key);
    _user = found;
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    await LocalStorage.clearSession();
    _user = null;
    notifyListeners();
  }
}