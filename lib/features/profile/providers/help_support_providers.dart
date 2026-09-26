import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulze_plus/core/network/network_providers.dart';
import 'package:pulze_plus/features/profile/data/help_support_repository.dart';
import 'package:pulze_plus/features/profile/models/help_support_models.dart';


final helpSupportRepositoryProvider = Provider<HelpSupportRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);

  return HelpSupportRepository(
    apiService: apiService,
  );
});

final faqProvider = FutureProvider<List<FAQModel>>((ref) async {
  final repository = ref.read(
    helpSupportRepositoryProvider,
  );

  return repository.getFaqs();
});
