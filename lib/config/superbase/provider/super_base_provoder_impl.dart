import 'package:aquayar/config/superbase/interfaces/super_base_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SuperBaseProviderImpl implements SuperBase {
  @override
  Future<void> superBaseInit() async {
    await Supabase.initialize(
      url: 'URL',
      anonKey:
          'ANNON KEY FROM SUPERBASE',
    );
  }
}
