import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_reactions/src/controllers/reactions_controller.dart';
import 'package:flutter_chat_reactions/src/models/chat_reactions_config.dart';
import 'package:flutter_chat_reactions/src/models/menu_item.dart';
import 'package:flutter_chat_reactions/src/utilities/hero_dialog_route.dart';
import 'package:flutter_chat_reactions/src/widgets/context_menu_widget.dart';

class ChatMessageWrapper extends StatelessWidget {
  final String messageId;
  final Widget Function(bool asPopup) child;
  final ReactionsController controller;
  final ChatReactionsConfig config;
  final Function(String)? onReactionAdded;
  final Function(String)? onReactionRemoved;
  final Function(MenuItem)? onMenuItemTapped;
  final Alignment alignment;
  final String userId;
  final void Function()? onTap;
  const ChatMessageWrapper({
    super.key,
    required this.messageId,
    required this.child,
    required this.controller,
    this.config = const ChatReactionsConfig(),
    this.onReactionAdded,
    this.onReactionRemoved,
    this.onMenuItemTapped,
    this.alignment = Alignment.centerRight,
    this.userId = "",
    this.onTap,
  });

  void _handleReactionTap(
    BuildContext context,
    String reaction,
    String userId,
  ) {
    if (config.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }

    if (reaction == '➕') {
      showModalBottomSheet(
        context: context,
        builder: (context) => config.emojiPickerBuilder!(
          context,
          (emoji) {
            Navigator.pop(context);
            _addReaction(emoji, userId);
          },
        ),
      );
    } else {
      _toggleReaction(reaction, userId);
    }
  }

  void _addReaction(String reaction, String userId) {
    controller.addReaction(messageId, reaction, userId: userId);
    onReactionAdded?.call(reaction);
  }

  void _toggleReaction(String reaction, String userId) {
    final wasReacted = controller.hasUserReacted(messageId, reaction, userId);
    controller.toggleReaction(messageId, reaction, userId: userId);

    if (wasReacted) {
      onReactionRemoved?.call(reaction);
    } else {
      onReactionAdded?.call(reaction);
    }
  }

  void _handleMenuItemTap(MenuItem item) {
    if (config.enableHapticFeedback) {
      HapticFeedback.selectionClick();
    }
    onMenuItemTapped?.call(item);
  }

  void _showReactionsDialog(
    BuildContext context,
  ) {
    Navigator.of(context).push(
      HeroDialogRoute(
        builder: (context) => ReactionsDialogWidget(
          messageId: messageId,
          messageWidget: child.call(true),
          controller: controller,
          config: config,
          onReactionTap: (reaction) => _handleReactionTap(
            context,
            reaction,
            userId,
          ),
          onMenuItemTap: _handleMenuItemTap,
          alignment: alignment,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: config.enableTap ? () => _showReactionsDialog(context) : null,
      onLongPress:
          config.enableLongPress ? () => _showReactionsDialog(context) : null,
      onDoubleTap:
          config.enableDoubleTap ? () => _showReactionsDialog(context) : null,
      child: child.call(false),
    );
  }
}
