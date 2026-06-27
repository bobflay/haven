import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../state/auth_state.dart';
import '../theme/haven_theme.dart';
import '../widgets/fade_up.dart';
import '../widgets/haven_widgets.dart';
import '../widgets/phone_frame.dart';

/// The unauthenticated experience: sign in, or create a new private space.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool signup = false;
  bool busy = false;
  String? error;

  final name = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  final pass2 = TextEditingController();

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    pass.dispose();
    pass2.dispose();
    super.dispose();
  }

  void _switch(bool toSignup) {
    setState(() {
      signup = toSignup;
      error = null;
    });
  }

  Future<void> _submit(Future<void> Function() action) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await action();
      // On success the AuthState notifies and _RootGate swaps us out.
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Could not reach Haven. Is the server running?');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.64),
          radius: 1.0,
          colors: [Color(0xFFF3EFE6), Color(0xFFE9E1D3), Color(0xFFE2D9C8)],
          stops: [0.0, 0.62, 1.0],
        ),
      ),
      child: signup ? _buildSignup(context) : _buildLogin(context),
    );
  }

  // --- LOGIN ----------------------------------------------------------------
  Widget _buildLogin(BuildContext context) {
    final auth = context.read<AuthState>();
    final ready = email.text.trim().isNotEmpty && pass.text.isNotEmpty && !busy;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: PhoneFrame.screenH),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 92, 30, 38),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeUp(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HavenLogo(size: 70, radius: 22),
                    const SizedBox(height: 26),
                    Text('Haven', style: news(size: 40, height: 1.05, letterSpacing: -0.4)),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 250,
                      child: Text('A quiet place to meet the urge — and watch it pass.',
                          style: hank(size: 16, height: 1.5, color: HavenColors.muted)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 44),
              FadeUp(
                delay: const Duration(milliseconds: 80),
                child: Column(
                  children: [
                    LabeledField(
                      label: 'Email',
                      field: HavenField(
                        controller: email,
                        hint: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 14),
                    LabeledField(
                      label: 'Passcode',
                      field: HavenField(
                        controller: pass,
                        hint: '······',
                        obscure: true,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 14),
                _ErrorText(error!),
              ],
              const SizedBox(height: 26),
              PrimaryButton(
                label: busy ? 'Opening…' : 'Enter your space',
                enabled: ready,
                onTap: () => _submit(() => auth.login(email.text.trim(), pass.text)),
              ),
              const SizedBox(height: 14),
              Center(
                child: _TextLink('New here? Create a space', () => _switch(true)),
              ),
              const SizedBox(height: 40),
              FadeUp(
                delay: const Duration(milliseconds: 160),
                child: Center(
                  child: Text(
                    '◇  Your entries stay private to you. Nothing here is shared without your say.',
                    textAlign: TextAlign.center,
                    style: hank(size: 12.5, height: 1.5, color: HavenColors.faint2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- SIGN UP --------------------------------------------------------------
  Widget _buildSignup(BuildContext context) {
    final auth = context.read<AuthState>();
    bool agree = _agree;
    final mismatch = pass2.text.isNotEmpty && pass.text != pass2.text;
    final valid = name.text.trim().isNotEmpty &&
        email.text.trim().isNotEmpty &&
        pass.text.length >= 6 &&
        pass.text == pass2.text &&
        agree &&
        !busy;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: PhoneFrame.screenH),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 62, 30, 38),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlyphButton(glyph: '‹', size: 22, color: HavenColors.muted, onTap: () => _switch(false)),
              const SizedBox(height: 18),
              FadeUp(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create your space',
                        style: news(size: 34, height: 1.1, letterSpacing: -0.3)),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 270,
                      child: Text("A private corner that's only yours. Takes a moment to set up.",
                          style: hank(size: 15.5, height: 1.5, color: HavenColors.muted)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              FadeUp(
                delay: const Duration(milliseconds: 80),
                child: Column(
                  children: [
                    LabeledField(
                      label: 'What should we call you?',
                      field: HavenField(
                        controller: name,
                        hint: 'A name or a nickname',
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 14),
                    LabeledField(
                      label: 'Email',
                      field: HavenField(
                        controller: email,
                        hint: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 14),
                    LabeledField(
                      label: 'Create a passcode',
                      field: HavenField(
                        controller: pass,
                        hint: 'At least 6 characters',
                        obscure: true,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LabeledField(
                          label: 'Confirm passcode',
                          field: HavenField(
                            controller: pass2,
                            hint: 'Type it once more',
                            obscure: true,
                            borderColor:
                                mismatch ? const Color(0xFFDABBA9) : HavenColors.borderSoft,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        if (mismatch)
                          Padding(
                            padding: const EdgeInsets.only(top: 7),
                            child: Text("Those passcodes don't match yet.",
                                style: hank(size: 12.5, color: HavenColors.clay)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _AgreeRow(
                value: agree,
                onTap: () => setState(() => _agree = !_agree),
              ),
              if (error != null) ...[
                const SizedBox(height: 14),
                _ErrorText(error!),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                label: busy ? 'Creating your space…' : 'Begin',
                enabled: valid,
                onTap: () => _submit(
                    () => auth.register(name.text.trim(), email.text.trim(), pass.text, pass2.text)),
              ),
              const SizedBox(height: 14),
              Center(child: _TextLink('Already have a space? Sign in', () => _switch(false))),
            ],
          ),
        ),
      ),
    );
  }

  bool _agree = false;
}

class _AgreeRow extends StatelessWidget {
  const _AgreeRow({required this.value, required this.onTap});
  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(top: 1),
            width: 21,
            height: 21,
            decoration: BoxDecoration(
              color: value ? HavenColors.sageDeep : HavenColors.card,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                  color: value ? HavenColors.sageDeep : const Color(0xFFD9D1C0), width: 1.5),
            ),
            child: value
                ? const Icon(Icons.check, size: 13, color: HavenColors.cream)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'I understand Haven is a personal reflection tool, not a substitute for my care team.',
              style: hank(size: 13, height: 1.45, color: HavenColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextLink extends StatelessWidget {
  const _TextLink(this.text, this.onTap);
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(text, style: hank(size: 14, weight: FontWeight.w500, color: HavenColors.sageDeep)),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6ECE5),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE7D2C5)),
      ),
      child: Text(text, style: hank(size: 13.5, height: 1.4, color: const Color(0xFFA8755E))),
    );
  }
}
