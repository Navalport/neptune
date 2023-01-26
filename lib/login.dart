import 'package:flutter/material.dart';
import 'package:mooringapp/defaultAppBar.dart';
import 'package:mooringapp/dockings.dart';
import 'package:mooringapp/interfaces.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),
      body: FutureBuilder<bool>(
          future: AuthInterface.isSignedIn(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasData && snapshot.data!) {
              Future.microtask(() => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const DockingsWidget()),
                    ModalRoute.withName(""),
                  ));
              return Container();
            } else {
              return FutureBuilder<dynamic>(
                future: AuthInterface.signInWithWebUI(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    final loginResult = snapshot.data;
                    if (loginResult["status"]) {
                      Future.microtask(() =>
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const DockingsWidget()),
                            ModalRoute.withName(""),
                          ));
                      return Container();
                    } else {
                      return Center(
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginWidget()),
                                  ModalRoute.withName(""),
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF38D36)),
                                child: Text(
                                  "Login",
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                              ),
                              const Text(
                                  "Ocorreu um erro ao fazer o login. Tente novamente."),
                            ],
                          ),
                        ),
                      );
                    }
                  } else {
                    return Column(
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const LoginWidget()),
                            ModalRoute.withName(""),
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF38D36)),
                          child: Text(
                            "Login",
                            style: Theme.of(context).textTheme.headline5,
                          ),
                        ),
                        const Text(
                            "Ocorreu um erro ao fazer o login. Tente novamente."),
                      ],
                    );
                  }
                },
              );
            }
          }),
    );
  }
}
