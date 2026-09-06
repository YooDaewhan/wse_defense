import 'package:flutter/material.dart';

import '../../../battle/tag/tag_registry.dart';
import '../../../domain/exchange/equipment_def.dart';
import '../../../domain/exchange/equipment_tag_grant.dart';
import '../../../domain/exchange/exchange_def.dart';

/// 05_FRONTEND.md §2 `/exchange`. 09_MILESTONES.md T-43: "장비 카드에 부여
/// 태그가 가장 크게 표시되고, 현재 편성 기준 '팀 태그 4→5' 안내".
class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({
    super.key,
    required this.config,
    required this.equipmentById,
    required this.heldItems,
    required this.formationTagLevels,
    required this.registry,
    required this.onExchange,
    required this.onUpgrade,
  });

  final ExchangeConfig config;
  final Map<String, EquipmentDef> equipmentById;

  /// itemId(ITM_SHARD_SUN_T1 등) -> 보유 수량.
  final Map<String, int> heldItems;

  /// 현재 편성의 팀 태그 레벨(tagId -> level) — `computeTeamTagPreview`
  /// 결과를 그대로 넘기면 된다.
  final Map<String, int> formationTagLevels;
  final TagRegistry registry;

  final void Function(ExchangeEntryDef entry) onExchange;
  final void Function(ExchangeEntryDef upgrade) onUpgrade;

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  String? _expandedEntryId;

  @override
  Widget build(BuildContext context) {
    final shopFamily = {
      for (final shop in widget.config.shops) shop.id: _familyOf(shop.id),
    };

    return DefaultTabController(
      length: widget.config.shops.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('교환소'),
          bottom: TabBar(
            tabs: [for (final shop in widget.config.shops) Tab(text: shop.nameKey, key: ValueKey('exchange_tab_${shop.id}'))],
          ),
        ),
        body: TabBarView(
          children: [
            for (final shop in widget.config.shops)
              _ShopView(
                shop: shop,
                family: shopFamily[shop.id]!,
                upgrades: widget.config.upgrades.where((u) => u.id.contains('_${shopFamily[shop.id]}_')).toList(),
                equipmentById: widget.equipmentById,
                heldItems: widget.heldItems,
                formationTagLevels: widget.formationTagLevels,
                registry: widget.registry,
                expandedEntryId: _expandedEntryId,
                onToggleExpand: (id) => setState(() => _expandedEntryId = _expandedEntryId == id ? null : id),
                onExchange: widget.onExchange,
                onUpgrade: widget.onUpgrade,
              ),
          ],
        ),
      ),
    );
  }

  static String _familyOf(String shopId) => shopId.replaceFirst('SHOP_DUNGEON_', '');
}

class _ShopView extends StatelessWidget {
  const _ShopView({
    required this.shop,
    required this.family,
    required this.upgrades,
    required this.equipmentById,
    required this.heldItems,
    required this.formationTagLevels,
    required this.registry,
    required this.expandedEntryId,
    required this.onToggleExpand,
    required this.onExchange,
    required this.onUpgrade,
  });

  final ShopDef shop;
  final String family;
  final List<ExchangeEntryDef> upgrades;
  final Map<String, EquipmentDef> equipmentById;
  final Map<String, int> heldItems;
  final Map<String, int> formationTagLevels;
  final TagRegistry registry;
  final String? expandedEntryId;
  final void Function(String entryId) onToggleExpand;
  final void Function(ExchangeEntryDef entry) onExchange;
  final void Function(ExchangeEntryDef upgrade) onUpgrade;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: ValueKey('exchange_shop_list_${shop.id}'),
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 12,
            children: [
              for (final tier in ['T1', 'T2', 'T3'])
                Text(
                  '$family$tier ${heldItems['ITM_SHARD_${family}_$tier'] ?? 0}',
                  key: ValueKey('exchange_held_${family}_$tier'),
                ),
            ],
          ),
        ),
        if (upgrades.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              children: [
                for (final upgrade in upgrades)
                  ElevatedButton(
                    key: ValueKey('exchange_upgrade_${upgrade.id}'),
                    onPressed: () => onUpgrade(upgrade),
                    child: Text('${upgrade.cost.first.item.split('_').last}×${upgrade.cost.first.amount}'
                        '→${upgrade.gain.id.split('_').last}×${upgrade.gain.amount}'),
                  ),
              ],
            ),
          ),
        for (final entry in shop.entries) _EntryCard(
          entry: entry,
          equipment: entry.gain.type == 'EQUIPMENT' ? equipmentById[entry.gain.id] : null,
          formationTagLevels: formationTagLevels,
          registry: registry,
          expanded: expandedEntryId == entry.id,
          onToggleExpand: () => onToggleExpand(entry.id),
          onExchange: () => onExchange(entry),
        ),
      ],
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.entry,
    required this.equipment,
    required this.formationTagLevels,
    required this.registry,
    required this.expanded,
    required this.onToggleExpand,
    required this.onExchange,
  });

  final ExchangeEntryDef entry;
  final EquipmentDef? equipment;
  final Map<String, int> formationTagLevels;
  final TagRegistry registry;
  final bool expanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onExchange;

  @override
  Widget build(BuildContext context) {
    final eq = equipment;
    final preview = eq == null
        ? null
        : previewEquipTagChange(
            currentFormationLevels: formationTagLevels,
            candidate: eq,
            enhanceLevel: 0,
            registry: registry,
          );

    return Card(
      key: ValueKey('exchange_entry_${entry.id}'),
      child: InkWell(
        onTap: eq != null ? onToggleExpand : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "부여 태그가 가장 크게 표시" -- 이름보다 태그를 먼저, 더 크게.
              if (eq?.grantTagId != null)
                Text(
                  eq!.grantTagId!,
                  key: ValueKey('exchange_tag_label_${entry.id}'),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              Text(eq?.nameKey ?? entry.gain.id),
              Text('비용: ${entry.cost.map((c) => '${c.item}×${c.amount}').join(', ')}'),
              // 07_DUNGEON_EXCHANGE.md §6.3: "+5 태그 추가는 UI에 반드시
              // 사전 표시한다" -- 강화하기 전(구매 시점)부터 미리 안내.
              if (eq?.grantTagId != null && eq!.tagBonusAtEnhance5)
                Text(
                  '+5 강화 시 ${eq.grantTagId} 태그 +1 추가 부여',
                  key: ValueKey('exchange_enhance5_hint_${entry.id}'),
                ),
              if (expanded && preview != null)
                Text(
                  '이 장비를 장착하면 팀 ${preview.tagId} 레벨이 '
                  '${preview.beforeLevel} → ${preview.afterLevel}가 됩니다.',
                  key: ValueKey('exchange_tag_preview_${entry.id}'),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  key: ValueKey('exchange_button_${entry.id}'),
                  onPressed: onExchange,
                  child: const Text('교환'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
