import 'package:flutter/material.dart';
import 'package:flutter_chat_reactions/src/models/reaction.dart';

/// A controller class to manage message reactions.
///
/// This controller handles adding, removing, and toggling reactions for messages,
/// and notifies listeners when the reaction state changes.
class ReactionsController extends ChangeNotifier {
  /// A map to store reactions for each message ID.
  final Map<String, List<Reaction>> _messageReactions = {};

  /// Creates a reactions controller.
  ReactionsController();

  /// Retrieves the list of reactions for a given [messageId].
  List<Reaction> getReactions(String messageId) {
    return _messageReactions[messageId] ?? [];
  }

  /// Returns a map of reaction counts for a given [messageId].
  Map<String, int> getReactionCounts(String messageId) {
    final reactions = getReactions(messageId);
    final counts = <String, int>{};
    for (final reaction in reactions) {
      counts[reaction.emoji] = (counts[reaction.emoji] ?? 0) + 1;
    }
    return counts;
  }

  /// Checks if the current user has reacted with a specific [emoji] to a [messageId].
  bool hasUserReacted(String messageId, String emoji, String userId) {
    final reactions = getReactions(messageId);
    return reactions.any((r) => r.emoji == emoji && r.userId == userId);
  }

  /// Adds a reaction with the given [emoji] to a [messageId].
  ///
  /// An optional [userName] can be provided.
  void addReaction(
    String messageId,
    String emoji, {
    String? userName,
    required String userId,
  }) {
    final reactions = _messageReactions[messageId] ?? [];
    final existingIndex = reactions.indexWhere(
      (r) => r.emoji == emoji && r.userId == userId,
    );

    if (existingIndex == -1) {
      reactions.add(Reaction(
        emoji: emoji,
        userId: userId,
        timestamp: DateTime.now(),
        userName: userName,
      ));
      _messageReactions[messageId] = reactions;
      notifyListeners();
    }
  }

  /// Removes a reaction with the given [emoji] from a [messageId].
  void removeReaction(String messageId, String emoji, String userId) {
    final reactions = _messageReactions[messageId] ?? [];
    reactions.removeWhere((r) => r.emoji == emoji && r.userId == userId);
    _messageReactions[messageId] = reactions;
    notifyListeners();
  }

  /// Toggles a reaction with the given [emoji] for a [messageId].
  ///
  /// If the user has already reacted with the emoji, it's removed. Otherwise, it's added.
  void toggleReaction(
    String messageId,
    String emoji, {
    String? userName,
    required String userId,
  }) {
    final reactions = _messageReactions[messageId] ?? [];
    final userReactionIndex = reactions.indexWhere((r) => r.userId == userId);

    if (userReactionIndex != -1) {
      final existingReaction = reactions[userReactionIndex];
      // If the user is selecting the same reaction, remove it.
      if (existingReaction.emoji == emoji) {
        removeReaction(messageId, emoji, userId);
      } else {
        // If the user is selecting a different reaction, replace the old one.
        reactions.removeAt(userReactionIndex);
        addReaction(messageId, emoji, userName: userName, userId: userId);
      }
    } else {
      // If the user has no reaction, add the new one.
      addReaction(messageId, emoji, userName: userName, userId: userId);
    }
  }

  /// Clears all reactions for a specific [messageId].
  void clearReactions(String messageId) {
    _messageReactions.remove(messageId);
    notifyListeners();
  }

  /// Clears all reactions for all messages.
  void clearAllReactions() {
    _messageReactions.clear();
    notifyListeners();
  }

  /// Loads a list of [reactions] for a given [messageId] from an external source.
  void loadReactions(String messageId, List<Reaction> reactions) {
    _messageReactions[messageId] = reactions;
    notifyListeners();
  }

  /// Returns an unmodifiable map of all reactions for persistence.
  Map<String, List<Reaction>> getAllReactions() {
    return Map.unmodifiable(_messageReactions);
  }
}
