import '../../data/local/tutorial_repository.dart';
import 'tutorial_gate.dart';
import 'tutorial_step.dart';

/// 05_FRONTEND.md §9.2 진행 관리. "중단 후 재개 가능"(T-34 완료조건) —
/// 생성 시점에 [store]에 이미 완료 기록된 단계는 전부 건너뛰고 시작하므로,
/// 앱을 재시작해 새 컨트롤러를 새로 만들어도 정확히 멈췄던 단계부터 이어진다.
class TutorialController {
  TutorialController({required this.steps, required this.store}) : _index = _firstIncompleteIndex(steps, store);

  final List<TutorialStep> steps;
  final TutorialStore store;

  int _index;

  int get currentIndex => _index;
  TutorialStep? get currentStep => _index < steps.length ? steps[_index] : null;
  bool get isComplete => _index >= steps.length;

  static int _firstIncompleteIndex(List<TutorialStep> steps, TutorialStore store) {
    for (var i = 0; i < steps.length; i++) {
      if (!store.isCompleted(steps[i].id)) return i;
    }
    return steps.length;
  }

  /// 매 프레임(또는 매 틱) 호출. 현재 단계의 게이트가 만족되면 완료
  /// 기록하고 다음 단계로 넘어간다 — true를 돌려주면 방금 한 단계
  /// 전진했다는 뜻(연출 트리거용).
  bool tick(TutorialContext ctx) {
    final step = currentStep;
    if (step == null) return false;
    if (!step.gate.isSatisfied(ctx)) return false;
    store.markCompleted(step.id);
    _index++;
    return true;
  }
}
