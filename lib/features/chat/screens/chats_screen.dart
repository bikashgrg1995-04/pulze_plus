import 'package:flutter/material.dart';
import 'package:pulze_plus/core/widgets/app_empty_state.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_search_field.dart';
import '../data/demo_chats.dart';
import '../models/chat_model.dart';
import '../widgets/chat_list_item.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key, this.onChatTap});

  final ValueChanged<ChatModel>? onChatTap;

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  String _searchQuery = '';

  List<ChatModel> get _filteredChats {
    if (_searchQuery.trim().isEmpty) {
      return demoChats;
    }

    final query = _searchQuery.trim().toLowerCase();

    return demoChats.where((chat) {
      return chat.name.toLowerCase().contains(query) ||
          chat.lastMessage.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chats = _filteredChats;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.massive,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chats',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              AppSearchField(
                hint: 'Search conversations',
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),

              const SizedBox(height: AppSpacing.md),

              Expanded(
                child: chats.isEmpty
                    ? const AppEmptyState(
                        title: 'No conversations found',
                        description:
                            'Try searching with a different name or message.',
                        icon: Icons.chat_bubble_outline_rounded,
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: chats.length,
                        separatorBuilder: (_, _) {
                          return const SizedBox(height: AppSpacing.xs);
                        },
                        itemBuilder: (context, index) {
                          final chat = chats[index];

                          return ChatListItem(
                            chat: chat,
                            onTap: () {
                              widget.onChatTap?.call(chat);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
