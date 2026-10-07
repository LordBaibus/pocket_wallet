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
  late final _address = TextEditingController(text: widget.profile.address);
  late final Set<String> _shown = {...widget.profile.shown};
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_name, _mobile, _org, _title, _city, _address]) {
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
        address: _address.text.trim(),
        shown: _shown,
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

  /// Field plus a switch: whether it appears on the pass / in the QR.
  Widget _row(String key, TextEditingController c, String hint, IconData icon,
      {TextInputType? type, bool last = false}) {
    return Row(
      children: [
        Expanded(
          child: PocketField(
            controller: c,
            placeholder: hint,
            icon: icon,
            keyboardType: type,
            textInputAction:
                last ? TextInputAction.done : TextInputAction.next,
          ),
        ),
        const SizedBox(width: 10),
        _toggle(key),
      ],
    );
  }

  Widget _toggle(String key) => GlassSwitch(
        value: _shown.contains(key),
        semanticLabel: 'Show on pass',
        onChanged: (v) => setState(() {
          if (v) {
            _shown.add(key);
          } else {
            _shown.remove(key);
          }
        }),
      );

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
                  placeholder: 'Full name (always shown)',
                  icon: CupertinoIcons.person,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                _row('mobile', _mobile, 'Mobile number', CupertinoIcons.phone,
                    type: TextInputType.phone),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'EMAIL  ${widget.profile.email}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: mono(12, color: kMuted, spacing: 0.3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _toggle('email'),
                  ],
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
                _row('organization', _org, 'Company / school',
                    CupertinoIcons.building_2_fill),
                const SizedBox(height: 12),
                _row('jobTitle', _title, 'Job title / course',
                    CupertinoIcons.briefcase),
                const SizedBox(height: 12),
                _row('address', _address, 'Address line (street, barangay)',
                    CupertinoIcons.house),
                const SizedBox(height: 12),
                _row('city', _city, 'City / province', CupertinoIcons.location,
                    last: true),
                const SizedBox(height: 14),
                Text(
                  'Switch on what appears on your pass and in the QR code.',
                  style: mono(11, color: kMuted, spacing: 0.2),
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
