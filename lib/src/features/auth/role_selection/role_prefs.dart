import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { ogrenci, isveren }
enum EmployerType { kurumsal, ozelDers }

class RolePrefs {
  static const _roleKey = 'selected_role';
  static const _empTypeKey = 'employer_type';

  // ---- ROLE ----
  static Future<void> save(UserRole role) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_roleKey, role.name);
  }

  static Future<UserRole?> load() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getString(_roleKey);
    if (v == null) return null;
    return UserRole.values.firstWhere(
      (e) => e.name == v,
      orElse: () => UserRole.ogrenci,
    );
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_roleKey);
  }

  // ---- EMPLOYER TYPE ----
  static Future<void> saveEmployerType(EmployerType t) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_empTypeKey, t.name);
  }

  static Future<EmployerType?> loadEmployerType() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getString(_empTypeKey);
    if (v == null) return null;
    return EmployerType.values.firstWhere(
      (e) => e.name == v,
      orElse: () => EmployerType.kurumsal,
    );
  }

  static Future<void> clearEmployerType() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_empTypeKey);
  }
}
