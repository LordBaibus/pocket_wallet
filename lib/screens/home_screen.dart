import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/auth_service.dart';
import '../services/profile.dart';
import '../services/wallet_service.dart';
import '../widgets/common.dart';
import '../widgets/dots.dart';
import 'add_card_screen.dart';
import 'card_detail_screen.dart';
import 'edit_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<WalletCard> _cards = [];
  bool _loading = true;
  final _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(() => setState(() => _query = _search.text.trim()));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _editProfile(Profile p) async {
    final saved = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(builder: (_) => EditProfileScreen(profile: p)),
    );
    if (saved == true && mounted) {
      setState(() {});
      showOk(context, 'Profile updated');
    }
  }

  Future<void> _copyInfo(Profile p) async {
    await Clipboard.setData(ClipboardData(text: p.qrText));
    if (mounted) showOk(context, 'Your info was copied');
  }

  Future<void> _load() async {
    try {
      final cards = await WalletService.instance.list();
      if (mounted) setState(() => _cards = cards);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openAdd() async {
    final added = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(builder: (_) => const AddCardScreen()),
    );
    if (added == true) _load();
  }

  Future<void> _openCard(WalletCard card) async {
    final changed = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(builder: (_) => CardDetailScreen(card: card)),
    );
    if (changed == true) _load();
  }

  void _printUser() {
    final text = AuthService.instance.printCurrentUser();
    GlassDialog.show(
      context: context,
      title: 'Current user',
      maxWidth: 340,
      content: SizedBox(
        height: 280,
        child: SingleChildScrollView(
          child: Text(
            text,
            style: mono(11, color: kInk, spacing: 0),
          ),
        ),
      ),
      actions: [
        GlassDialogAction(
          label: 'Close',
          isPrimary: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Future<void> _confirmSignOut() async {
    await showPocketConfirm(
      context,
      tag: '05 SESSION',
      title: 'Sign out?',
      message: 'Your cards stay safe in your account. Sign back in anytime.',
      confirmLabel: 'Sign out',
      icon: CupertinoIcons.power,
      onConfirm: () async {
        try {
          await AuthService.instance.signOut();
          // AuthGate returns to Login by itself.
        } catch (e) {
          if (mounted) showError(context, e);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final profile = Profile.fromUser(user);
    final shown = _query.isEmpty
        ? _cards
        : _cards
            .where((c) =>
                c.label.toLowerCase().contains(_query.toLowerCase()) ||
                c.number.toLowerCase().contains(_query.toLowerCase()))
            .toList();
    final provider =
        (user?.appMetadata['provider'] ?? 'email').toString().toUpperCase();
    final lastIn = (user?.lastSignInAt ?? '').split('T').first;

    return GlassScaffold(
      background: const PocketBackground(),
      appBar: GlassAppBar(
        leading: BarButton(
          icon: CupertinoIcons.power,
          label: 'Sign out',
          color: kAccent,
          onPressed: _confirmSignOut,
        ),
        actions: [
          BarButton(
            icon: CupertinoIcons.add,
            label: 'Add card',
            onPressed: _openAdd,
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          CupertinoSliverRefreshControl(onRefresh: _load),
          SliverPadding(
            padding: pagePadding(context, bottom: 48),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                PocketHeader(
                  title: 'Pocket Wallet',
                  subtitle: 'Digital ID & card wallet',
                  status: _loading
                      ? 'Syncing…'
                      : 'Synced · ${_cards.length} '
                          '${_cards.length == 1 ? 'card' : 'cards'}',
                ),
                _passTile(profile),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Tile(
                        index: '02',
                        title: 'Cards',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _cards.length.toString().padLeft(2, '0'),
                              style: dot(44, color: kAccent),
                            ),
                            const SizedBox(height: 10),
                            const DotWave(height: 34, columns: 12, hotColumns: 2),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Tile(
                        index: '03',
                        title: 'Session',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(provider, style: dot(26)),
                            const SizedBox(height: 10),
                            Text('LAST SIGN-IN',
                                style: mono(9, color: kMuted)),
                            const SizedBox(height: 2),
                            Text(lastIn.isEmpty ? '—' : lastIn,
                                style: mono(12, color: kInk, spacing: 0.4)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Tile(
                  index: '04',
                  title: 'Actions',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GlassAction(
                        label: 'Edit profile',
                        icon: CupertinoIcons.pencil,
                        onTap: () => _editProfile(profile),
                      ),
                      const SizedBox(height: 10),
                      GlassAction(
                        label: 'Copy my info',
                        icon: CupertinoIcons.doc_on_clipboard,
                        primary: false,
                        onTap: () => _copyInfo(profile),
                      ),
                      const SizedBox(height: 10),
                      GlassAction(
                        label: 'Print current user',
                        icon: CupertinoIcons.person_crop_circle,
                        primary: false,
                        onTap: _printUser,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 14),
                  child: Text('MY CARDS',
                      style: mono(13, color: kOnBg, spacing: 1.6)),
                ),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CupertinoActivityIndicator()),
                  )
                else if (_cards.isEmpty)
                  _emptyState()
                else ...[
                  PocketField(
                    controller: _search,
                    placeholder: 'Search cards',
                    icon: CupertinoIcons.search,
                  ),
                  const SizedBox(height: 14),
                  if (shown.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('No cards match "$_query".',
                          style: mono(12, color: kOnBg)),
                    ),
                  for (var i = 0; i < shown.length; i++)
                    _cardTile(i + 1, shown[i]),
                ],
                const Tagline('Your cards. One pocket.'),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passTile(Profile p) {
    final name = p.displayName;
    final short = p.id.length >= 8 ? p.id.substring(0, 8) : p.id;
    final sub = [
      if (p.show('jobTitle')) p.jobTitle,
      if (p.show('organization')) p.organization,
    ].where((e) => e.trim().isNotEmpty).join(' · ');
    Widget info(String label, String value) => value.trim().isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    width: 64,
                    child: Text(label, style: mono(10, color: kMuted))),
                Expanded(
                  child: Text(value,
                      style: mono(12, color: kInk, spacing: 0.3)),
                ),
              ],
            ),
          );
    return Tile(
      index: '01',
      title: 'Pocket pass',
      trailing: StatusChip('${(p.completeness * 100).round()}% complete'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: dot(26),
                    ),
                    if (sub.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(sub,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: mono(12, color: kMuted, spacing: 0.2)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              DotRing(
                size: 64,
                dots: 36,
                child: Text(
                  name.isEmpty ? '?' : name[0].toUpperCase(),
                  style: dot(20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (p.show('mobile'))
            info('MOBILE',
                p.mobile.isEmpty ? '— add in Edit profile' : p.mobile),
          if (p.show('email')) info('EMAIL', p.email),
          if (p.show('address')) info('ADDRESS', p.address),
          if (p.show('city')) info('CITY', p.city),
          const SizedBox(height: 18),
          Center(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F1EE),
                borderRadius: BorderRadius.circular(18),
              ),
              child: QrImageView(
                data: p.qrText,
                size: 200,
                errorCorrectionLevel: QrErrorCorrectLevel.L,
                backgroundColor: const Color(0xFFF4F1EE),
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF111111),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF111111),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text('ID', style: mono(10, color: kMuted)),
              const SizedBox(width: 8),
              Text(short.toUpperCase(), style: mono(12, color: kInk)),
              const Spacer(),
              Text('SCAN TO VIEW ALL INFO', style: mono(9, color: kMuted)),
              const SizedBox(width: 6),
              const Icon(CupertinoIcons.lock_fill, size: 14, color: kMuted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Tile(
      index: '05',
      title: 'Empty',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NO CARDS YET', style: dot(24)),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your gym, library,\nschool or store card.',
            style: mono(12, color: kMuted, spacing: 0.2).copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _cardTile(int n, WalletCard c) {
    final color = hexToColor(c.color);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Tile(
        index: (n + 4).toString().padLeft(2, '0'),
        title: 'Card',
        onTap: () => _openCard(c),
        trailing: c.isFavorite
            ? const Icon(CupertinoIcons.star_fill, size: 14, color: kAccent)
            : Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 46,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: dot(22),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    c.number,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: mono(12, color: kMuted, spacing: 0.6),
                  ),
                ],
              ),
            ),
            const Icon(CupertinoIcons.qrcode, color: kInk, size: 26),
          ],
        ),
      ),
    );
  }
}
