import 'package:flutter/material.dart';

//ignore: must_be_immutable
class SignInScaffold extends StatelessWidget {
  FloatingActionButton? _floatingActionButton;
  final Widget body;

  SignInScaffold({required this.body, courses, modules, floatingActionButton})
      : _floatingActionButton = floatingActionButton;

  @override
  Widget build(BuildContext context) {
    if (this._floatingActionButton != null) {
      return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            appBar: AppBar(
                elevation: 1,
                title: Text(
                  'Wits Overflow',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                actions: []),
            body: this.body),
      );
    } else {
      return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            appBar: AppBar(
                elevation: 1,
                title: Text(
                  'Wits Overflow',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                actions: []),
            body: this.body),
      );
    }
  }
}
