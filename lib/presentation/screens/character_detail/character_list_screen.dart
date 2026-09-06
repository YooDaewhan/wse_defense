import 'package:flutter/material.dart';

import '../../../battle/defs/datapack.dart';

/// 05_FRONTEND.md §2 `/friends`: "친구" = 보유 캐릭터(동료) 그리드 --
/// 실제 소셜 친구 기능이 아니다(백엔드 자체가 없음). 보유 캐릭터를 눌러
/// 상세(`/friends/:id`)로 들어간다.
class CharacterListScreen extends StatelessWidget {
  const CharacterListScreen({super.key, required this.ownedCharacterIds, required this.datapack, required this.onCharacterTap});

  final Set<String> ownedCharacterIds;
  final Datapack datapack;
  final void Function(String characterId) onCharacterTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('동료')),
      body: ownedCharacterIds.isEmpty
          ? const Center(child: Text('아직 보유한 동료가 없습니다', key: ValueKey('friends_empty')))
          : GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 3,
              children: [
                for (final characterId in ownedCharacterIds)
                  InkWell(
                    key: ValueKey('friends_card_$characterId'),
                    onTap: () => onCharacterTap(characterId),
                    child: Card(
                      child: Center(child: Text(datapack.characterById(characterId)?.nameKey ?? characterId)),
                    ),
                  ),
              ],
            ),
    );
  }
}
