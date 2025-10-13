

// ==================== utils/trie.dart ====================

import 'package:scholarship/pages/Search_Page/models/scholarship.dart';

class TrieNode {
  Map<String, TrieNode> children = {};
  bool isEndOfWord = false;
  Scholarship? scholarship;
}

class Trie {
  final TrieNode root = TrieNode();

  void insert(String word, Scholarship scholarship) {
    TrieNode node = root;
    String lowerWord = word.toLowerCase();

    for (int i = 0; i < lowerWord.length; i++) {
      String char = lowerWord[i];
      if (!node.children.containsKey(char)) {
        node.children[char] = TrieNode();
      }
      node = node.children[char]!;
    }
    node.isEndOfWord = true;
    node.scholarship = scholarship;
  }

  List<Scholarship> search(String prefix) {
    TrieNode? node = root;
    String lowerPrefix = prefix.toLowerCase();

    for (int i = 0; i < lowerPrefix.length; i++) {
      String char = lowerPrefix[i];
      if (!node!.children.containsKey(char)) {
        return [];
      }
      node = node.children[char];
    }

    return _getAllWords(node!, lowerPrefix);
  }

  List<Scholarship> _getAllWords(TrieNode node, String prefix) {
    List<Scholarship> results = [];

    if (node.isEndOfWord && node.scholarship != null) {
      results.add(node.scholarship!);
    }

    node.children.forEach((char, childNode) {
      results.addAll(_getAllWords(childNode, prefix + char));
    });

    return results;
  }
}