import 'package:flutter/material.dart';

import '../services/fan_session.dart';

class FanAccountScreen extends StatefulWidget {
  const FanAccountScreen({super.key, this.session});

  final FanSession? session;

  @override
  State<FanAccountScreen> createState() => _FanAccountScreenState();
}

class _FanAccountScreenState extends State<FanAccountScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final FanSession _session = widget.session ?? FanSession.instance;
  bool _registerMode = false;
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      await _session.restore();
    } catch (error) {
      _error = _messageFor(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final account = _registerMode
          ? await _session.register(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
            )
          : await _session.signIn(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
      if (!mounted) return;
      _passwordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in as ${account.displayName}.')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) setState(() => _error = _messageFor(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _signOut() async {
    try {
      await _session.signOut();
      if (mounted) setState(() => _error = null);
    } catch (error) {
      if (mounted) setState(() => _error = _messageFor(error));
    }
  }

  String _messageFor(Object error) => error.toString().replaceFirst(
    RegExp(r'^AfconApiException\(\d+, [^)]*\): '),
    '',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Fan account')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Icon(
                  Icons.sports_soccer_rounded,
                  size: 52,
                  color: Color(0xFF880209),
                ),
                const SizedBox(height: 12),
                Text(
                  _session.isSignedIn
                      ? 'Welcome, ${_session.account!.displayName}'
                      : _registerMode
                      ? 'Create your fan account'
                      : 'Sign in to AFCON Fan',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _session.isSignedIn
                      ? _session.account!.email
                      : 'Your account keeps your posts, follows and notification preferences synced.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF666666)),
                ),
                const SizedBox(height: 24),
                if (_session.isSignedIn)
                  OutlinedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign out'),
                  )
                else ...[
                  if (_registerMode)
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Name'),
                      textInputAction: TextInputAction.next,
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(labelText: 'Email'),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    autofillHints: [
                      _registerMode
                          ? AutofillHints.newPassword
                          : AutofillHints.password,
                    ],
                    decoration: InputDecoration(
                      labelText: 'Password',
                      helperText: _registerMode
                          ? 'Use at least 12 characters.'
                          : null,
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_registerMode ? 'Create account' : 'Sign in'),
                  ),
                  TextButton(
                    onPressed: _submitting
                        ? null
                        : () => setState(() {
                            _registerMode = !_registerMode;
                            _error = null;
                          }),
                    child: Text(
                      _registerMode
                          ? 'Already have an account? Sign in'
                          : 'New here? Create an account',
                    ),
                  ),
                ],
                if (_error != null && _session.isSignedIn) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
  );
}
