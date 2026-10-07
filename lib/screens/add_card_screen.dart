import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../services/wallet_service.dart';
import '../widgets/common.dart';

const kCardColors = [
  '#FF4A1C',
  '#E5484D',
  '#12A594',
  '#F5A524',
  '#8E4EC6',
  '#1F8FFF',
  '#30A46C',
  '#8C8C94',
];

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _label = TextEditingController();
  final _number = TextEditingController();
  String _color = kCardColors.first;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _label.addListener(() => setState(() {}));
    _number.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _label.dispose();
    _number.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final label = _label.text.trim();
    final number = _number.text.trim();
    if (label.isEmpty || number.isEmpty) {
      showError(context, 'Enter a card name and member number.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      await WalletService.instance
          .add(label: label, number: number, color: _color);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = hexToColor(_color);
    final previewLabel =
        _label.text.trim().isEmpty ? 'CARD NAME' : _label.text.trim().toUpperCase();
    final previewNumber =
        _number.text.trim().isEmpty ? '0000 0000' : _number.text.trim();

    return GlassScaffold(
      background: const PocketBackground(),
      appBar: GlassAppBar(leading: backButton(context)),
      body: ListView(
        padding: pagePadding(context),
        children: [
          const PocketHeader(
            title: 'Add card',
            subtitle: 'Gym, library, school, store',
            status: 'Saved to your account',
          ),
          Tile(
            index: '01',
            title: 'Details',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PocketField(
                  controller: _label,
                  placeholder: 'Card name (e.g. Gym)',
                  icon: CupertinoIcons.tag,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                PocketField(
                  controller: _number,
                  placeholder: 'Member / card number',
                  icon: CupertinoIcons.number,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _save(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Tile(
            index: '02',
            title: 'Color',
            child: Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final hex in kCardColors)
                  GestureDetector(
                    onTap: () => setState(() => _color = hex),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: hexToColor(hex),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              _color == hex ? kInk : const Color(0x00000000),
                          width: 3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Tile(
            index: '03',
            title: 'Preview',
            trailing: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
                      Text(previewLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: dot(22)),
                      const SizedBox(height: 4),
                      Text(previewNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: mono(12, color: kMuted)),
                    ],
                  ),
                ),
                const Icon(CupertinoIcons.qrcode, color: kInk, size: 26),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GlassAction(label: 'Save card', busy: _busy, onTap: _save),
        ],
      ),
    );
  }
}
