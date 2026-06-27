import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/data_store.dart';
import '../state/nav_state.dart';
import '../theme/haven_theme.dart';
import '../widgets/haven_widgets.dart';
import '../widgets/phone_frame.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    final store = context.read<DataStore>();
    if (text.isEmpty || store.chatBusy) return;
    _input.clear();
    setState(() {});
    await store.sendChat(text);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.enter &&
        !HardwareKeyboard.instance.isShiftPressed) {
      _send();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DataStore>();
    final nav = context.read<NavState>();
    _scrollToBottom();

    final canSend = _input.text.trim().isNotEmpty && !store.chatBusy;

    return ColoredBox(
      color: HavenColors.cream,
      child: Column(
        children: [
          // header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 58, 20, 14),
            decoration:
                const BoxDecoration(border: Border(bottom: BorderSide(color: HavenColors.border))),
            child: Row(
              children: [
                GlyphButton(glyph: '‹', size: 24, onTap: () => nav.go(HavenScreen.home)),
                const SizedBox(width: 8),
                const HavenLogo(size: 36, radius: 11, strokeScale: 1.25),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Haven', style: news(size: 17, weight: FontWeight.w500, height: 1.1)),
                    Text('A calm companion · always here',
                        style: hank(size: 11.5, color: HavenColors.muted2)),
                  ],
                ),
              ],
            ),
          ),
          // messages
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
              children: [
                ...store.chat.map((m) => _Bubble(message: m)),
                if (store.chatBusy) const _ReflectingBubble(),
              ],
            ),
          ),
          // input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 26),
            decoration: const BoxDecoration(
              color: HavenColors.cream,
              border: Border(top: BorderSide(color: HavenColors.border)),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 90),
                        child: Focus(
                          focusNode: _focus,
                          onKeyEvent: _onKey,
                          child: TextField(
                            controller: _input,
                            minLines: 1,
                            maxLines: 4,
                            onChanged: (_) => setState(() {}),
                            style: hank(size: 14.5, color: HavenColors.ink),
                            cursorColor: HavenColors.sageDeep,
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: HavenColors.card,
                              hintText: "Say what's on your mind…",
                              hintStyle: hank(size: 14.5, color: HavenColors.faint),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(color: HavenColors.borderSoft),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(color: HavenColors.sage),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    GestureDetector(
                      onTap: canSend ? _send : null,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: canSend ? HavenColors.sageDeep : HavenColors.disabledBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_upward_rounded,
                            size: 22, color: canSend ? HavenColors.cream : HavenColors.faint2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Text('Haven is a companion, not a clinician. In crisis, contact your care team or 988.',
                    textAlign: TextAlign.center,
                    style: hank(size: 10.5, color: const Color(0xFFC4BCAE))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final user = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: LayoutBuilder(
        builder: (context, c) => Row(
          mainAxisAlignment: user ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: c.maxWidth * 0.78),
              child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
              decoration: BoxDecoration(
                color: user ? HavenColors.sageDeep : HavenColors.card,
                border: user ? null : Border.all(color: HavenColors.border),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(user ? 18 : 5),
                  bottomRight: Radius.circular(user ? 5 : 18),
                ),
              ),
              child: Text(message.text,
                  style: hank(
                      size: 14.5,
                      height: 1.45,
                      color: user ? HavenColors.cream : HavenColors.ink)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReflectingBubble extends StatelessWidget {
  const _ReflectingBubble();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: HavenColors.card,
            border: Border.all(color: HavenColors.border),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(18),
            ),
          ),
          child: Text('Haven is reflecting…',
              style: news(size: 14, italic: true, color: HavenColors.muted2)),
        ),
      ),
    );
  }
}
