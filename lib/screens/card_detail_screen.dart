import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/wallet_service.dart';
import '../widgets/common.dart';

/// Full-screen QR to show at the counter.
class CardDetailScreen extends StatelessWidget {
  const CardDetailScreen({super.key, required this.card});
  final WalletCard card;

  void _confirmDelete(BuildContext context) {
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
          if (context.mounted) Navigator.of(context).pop(true);
        } catch (e) {
          if (context.mounted) showError(context, e);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = hexToColor(card.color);
    return GlassScaffold(
      background: const PocketBackground(),
      appBar: GlassAppBar(
        leading: backButton(context),
        actions: [
          GlassIconButton(
            icon: const Icon(CupertinoIcons.trash),
            semanticLabel: 'Delete card',
            onPressed: () => _confirmDelete(context),
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
          const Tagline('Scan. Done.'),
        ],
      ),
    );
  }
}
