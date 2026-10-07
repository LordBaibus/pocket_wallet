import 'package:supabase_flutter/supabase_flutter.dart';

class WalletCard {
  WalletCard({
    required this.id,
    required this.label,
    required this.number,
    required this.color,
  });

  final String id;
  final String label;
  final String number;
  final String color; // '#RRGGBB'

  factory WalletCard.fromMap(Map<String, dynamic> m) => WalletCard(
        id: m['id'] as String,
        label: m['label'] as String,
        number: m['number'] as String,
        color: (m['color'] as String?) ?? '#5B5BD6',
      );
}

class WalletService {
  WalletService._();
  static final instance = WalletService._();

  SupabaseQueryBuilder get _table => Supabase.instance.client.from('cards');

  Future<List<WalletCard>> list() async {
    final rows = await _table.select().order('created_at', ascending: true);
    return (rows as List)
        .map((r) => WalletCard.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  /// user_id is filled by the database default (auth.uid()).
  Future<void> add({
    required String label,
    required String number,
    required String color,
  }) async {
    await _table.insert({'label': label, 'number': number, 'color': color});
  }

  Future<void> delete(String id) async {
    await _table.delete().eq('id', id);
  }
}
