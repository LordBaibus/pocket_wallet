import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../services/auth_service.dart';
import '../services/profile.dart';
import '../widgets/common.dart';

/// Edit the details that appear in the QR pass.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profile});
  final Profile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final _name = TextEditingController(text: widget.profile.fullName);
  late final _mobile = TextEditingController(text: widget.profile.mobile);
  late final _org = TextEditingController(text: widget.profile.organization);
  late final _title = TextEditingController(text: widget.profile.jobTitle);
  late final _city = TextEditingController(text: widget.profile.city);
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_name, _mobile, _org, _title, _city]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _mobile.text.trim().isEmpty) {
      showError(context, 'Name and mobile number are required.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      final p = Profile(
        id: widget.profile.id,
        email: widget.profile.email,
        fullName: _name.text.trim(),
        mobile: _mobile.text.trim(),
        organization: _org.text.trim(),
        jobTitle: _title.text.trim(),
        city: _city.text.trim(),
      );
      await AuthService.instance.updateProfile(p);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      background: const PocketBackground(),
      appBar: GlassAppBar(leading: backButton(context)),
      body: ListView(
        padding: pagePadding(context),
        children: [
          const PocketHeader(
            title: 'Edit profile',
            subtitle: 'Shown when your pass is scanned',
            status: 'Everything here goes into your QR',
          ),
          Tile(
            index: '01',
            title: 'Identity',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PocketField(
                  controller: _name,
                  placeholder: 'Full name',
                  icon: CupertinoIcons.person,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                PocketField(
                  controller: _mobile,
                  placeholder: 'Mobile number',
                  icon: CupertinoIcons.phone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Tile(
            index: '02',
            title: 'Details',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PocketField(
                  controller: _org,
                  placeholder: 'Company / school',
                  icon: CupertinoIcons.building_2_fill,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                PocketField(
                  controller: _title,
                  placeholder: 'Job title / course',
                  icon: CupertinoIcons.briefcase,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                PocketField(
                  controller: _city,
                  placeholder: 'City',
                  icon: CupertinoIcons.location,
                  onSubmitted: (_) => _save(),
                ),
                const SizedBox(height: 18),
                GlassAction(label: 'Save profile', busy: _busy, onTap: _save),
              ],
            ),
          ),
          const Tagline('Make it yours'),
        ],
      ),
    );
  }
}
