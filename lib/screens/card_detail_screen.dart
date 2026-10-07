import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/wallet_service.dart';
import '../widgets/common.dart';

/// Full-screen QR to show at the counter, plus favorite and notes.
class CardDetailScreen extends StatefulWidget {
  const CardDetailScreen({super.key, required this.card});
  final WalletCard card;

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  late bool _fav = widget.card.isFavorite;
  late final _notes = TextEditingController(text: widget.card.notes);
  bool _busy = false;
  bool _changed = false;

  WalletCard get card => widget.card;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _toggleFav() async {
    final next = !_fav;
    setState(() => _fav = next);
    try {
      await WalletService.instance.update(card.id, isFavorite: next);
      _changed = true;
    } catch (e) {
      if (mounted) {
        setState(() => _fav = !next);
        showError(context, e);
      }
    }
  }

  Future<void> _saveNotes() async {
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      await WalletService.instance.update(card.id, notes: _notes.text.trim());
      _changed = true;
      if (mounted) showOk(context, 'Notes saved');
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _confirmDelete() {
    showPocketConfirm(
      context,
      tag: 'CARD',
      title: 'Delete card?',
      message:
          '"${card.label}" will be removed from all your devices. This cannot be undone.',
      confirmLabel: 'Delete',
      icon: CupertinoIcons.delete,
      onConfirm: () async {
        try {
          await WalletService.instance.delete(card.id);
          if (mounted) Navigator.of(context).pop(true);
        } catch (e) {
          if (mounted) showError(context, e);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = hexToColor(card.color);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_changed);
      },
      child: GlassScaffold(
        background: const PocketBackground(),
        appBar: GlassAppBar(
          leading: BarButton(
            icon: CupertinoIcons.back,
            label: 'Back',
            onPressed: () => Navigator.of(context).pop(_changed),
          ),
          actions: [
            BarButton(
              icon: _fav ? CupertinoIcons.star_fill : CupertinoIcons.star,
              label: 'Favorite',
              color: _fav ? kAccent : kInk,
              onPressed: _toggleFav,
            ),
            BarButton(
              icon: CupertinoIcons.delete,
              label: 'Delete card',
              onPressed: _confirmDelete,
            ),
          ],
        ),
        body: ListView(
          padding: pagePadding(context),
          children: [
            PocketHeader(
              title: card.label,
              subtitle: 'Show at the counter',
              status: 'Ready to scan',
            ),
            Tile(
              index: '01',
              title: 'Scan code',
              trailing: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F1EE),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: QrImageView(
                        data: card.number,
                        size: 240,
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
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
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
                            Text('NUMBER', style: mono(10, color: kMuted)),
                            const SizedBox(height: 2),
                            Text(card.number,
                                style: dot(26, spacing: 2),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Tile(
              index: '02',
              title: 'Notes',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PocketField(
                    controller: _notes,
                    placeholder: 'PIN, expiry, branch, perks…',
                    icon: CupertinoIcons.pencil,
                    onSubmitted: (_) => _saveNotes(),
                  ),
                  const SizedBox(height: 14),
                  GlassAction(
                    label: 'Save notes',
                    primary: false,
                    busy: _busy,
                    onTap: _saveNotes,
                  ),
                ],
              ),
            ),
            const Tagline('Scan. Done.'),
          ],
        ),
      ),
    );
  }
}
