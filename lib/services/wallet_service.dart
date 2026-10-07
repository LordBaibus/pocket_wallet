import 'package:supabase_flutter/supabase_flutter.dart';

class WalletCard {
  WalletCard({
    required this.id,
    required this.label,
    required this.number,
    required this.color,
    this.notes = '',
    this.isFavorite = false,
  });

  final String id;
  final String label;
  final String number;
  final String color; // '#RRGGBB'
  final String notes;
  final bool isFavorite;

  factory WalletCard.fromMap(Map<String, dynamic> m) => WalletCard(
        id: m['id'] as String,
        label: m['label'] as String,
        number: m['number'] as String,
        color: (m['color'] as String?) ?? '#5B5BD6',
        notes: (m['notes'] as String?) ?? '',
        isFavorite: (m['is_favorite'] as bool?) ?? false,
      );
}

class WalletService {
  WalletService._();
  static final instance = WalletService._();

  SupabaseQueryBuilder get _table => Supabase.instance.client.from('cards');

  Future<List<WalletCard>> list() async {
    final rows = await _table.select().order('created_at', ascending: true);
    final cards = (rows as List)
        .map((r) => WalletCard.fromMap(r as Map<String, dynamic>))
        .toList();
    // Favorites first; otherwise keep creation order (sort is stable).
    cards.sort((a, b) =>
        (b.isFavorite ? 1 : 0).compareTo(a.isFavorite ? 1 : 0));
    return cards;
  }

  /// user_id is filled by the database default (auth.uid()).
  Future<void> add({
    required String label,
    required String number,
    required String color,
  }) async {
    await _table.insert({'label': label, 'number': number, 'color': color});
  }

  /// Needs the `notes` / `is_favorite` columns (see supabase/schema.sql).
  Future<void> update(String id,
      {String? notes, bool? isFavorite}) async {
    final patch = <String, dynamic>{};
    if (notes != null) patch['notes'] = notes;
    if (isFavorite != null) patch['is_favorite'] = isFavorite;
    if (patch.isEmpty) return;
    await _table.update(patch).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _table.delete().eq('id', id);
  }
}
