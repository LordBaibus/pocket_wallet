import 'package:supabase_flutter/supabase_flutter.dart';

/// The member's profile, stored in Supabase auth user metadata.
/// Fields the member can choose to show (name is always shown).
const allShareable = {
  'mobile',
  'email',
  'organization',
  'jobTitle',
  'city',
  'address',
};

class Profile {
  const Profile({
    required this.id,
    required this.email,
    this.fullName = '',
    this.mobile = '',
    this.organization = '',
    this.jobTitle = '',
    this.city = '',
    this.address = '',
    this.shown = allShareable,
  });

  final String id;
  final String email;
  final String fullName;
  final String mobile;
  final String organization;
  final String jobTitle;
  final String city;
  final String address;
  final Set<String> shown;

  bool show(String key) => shown.contains(key);

  factory Profile.fromUser(User? u) {
    final m = u?.userMetadata ?? const <String, dynamic>{};
    String s(String k) => (m[k] ?? '').toString();
    return Profile(
      id: u?.id ?? '',
      email: u?.email ?? '',
      fullName: s('full_name').isNotEmpty ? s('full_name') : s('name'),
      mobile: s('mobile'),
      organization: s('organization'),
      jobTitle: s('job_title'),
      city: s('city'),
      address: s('address'),
      shown: m['shown'] is List
          ? (m['shown'] as List).map((e) => e.toString()).toSet()
          : allShareable,
    );
  }

  String get displayName => fullName.isEmpty ? 'Member' : fullName;

  Map<String, dynamic> toMeta() => {
        'full_name': fullName,
        'mobile': mobile,
        'organization': organization,
        'job_title': jobTitle,
        'city': city,
        'address': address,
        'shown': shown.toList(),
      };

  /// Share of optional profile fields that are filled in (0..1).
  double get completeness {
    final f = [fullName, mobile, organization, jobTitle, city, address];
    return f.where((e) => e.trim().isNotEmpty).length / f.length;
  }

  /// Plain text in the QR code. A scanner shows all of it as text (it is not
  /// a vCard, so it does not prompt "add to contacts").
  String get qrText {
    final lines = <String>['POCKET WALLET MEMBER'];
    void add(String label, String v) {
      if (v.trim().isNotEmpty) lines.add('$label: ${v.trim()}');
    }

    add('Name', fullName);
    if (show('mobile')) add('Mobile', mobile);
    if (show('email')) add('Email', email);
    if (show('organization')) add('Organization', organization);
    if (show('jobTitle')) add('Title', jobTitle);
    if (show('address')) add('Address', address);
    if (show('city')) add('City', city);
    add('Member ID', id.length >= 8 ? id.substring(0, 8).toUpperCase() : id);
    return lines.join('\n');
  }
}
