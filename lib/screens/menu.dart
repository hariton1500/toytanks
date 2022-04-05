import 'package:flame/components.dart';

class MenuElement extends TextComponent with Tappable {
  MenuElement({required Vector2 position, required String text}) : super(position: position, text: text);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    textRenderer = regular
  }

  @override
  void onTap() {

  }
}