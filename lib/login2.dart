import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mooringapp/interfaces.dart';
import 'package:mooringapp/voyages.dart';
import 'package:url_launcher/url_launcher.dart';

enum NavState { login, recover, code }

class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  NavState _navState = NavState.login;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final bool _inProgress = false;
  final Future<bool> _isSignedIn$ = AuthInterface.isSignedIn();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: _isSignedIn$,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasData && snapshot.data!) {
              Future.microtask(() => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const DockingsWidget()),
                    ModalRoute.withName(""),
                  ));
              return Container();
            }

            return Center(
              child: IntrinsicHeight(
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SvgPicture.asset("assets/NP_H_COR_48px.svg"),
                        const SizedBox(height: 24),
                        Builder(
                          builder: (context) {
                            switch (_navState) {
                              case NavState.login:
                                return Column(
                                  children: [
                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.end,
                                    //   children: [
                                    //     RichText(
                                    //       text: TextSpan(
                                    //         text: 'Esqueceu a senha?',
                                    //         style: const TextStyle(
                                    //           color: Colors.blue,
                                    //         ),
                                    //         recognizer: TapGestureRecognizer()
                                    //           ..onTap = () => setState(() {
                                    //                 _navState = NavState.recover;
                                    //               }),
                                    //       ),
                                    //     )
                                    //   ],
                                    // ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _emailController,
                                      cursorColor: const Color(0xFFE4F8EF),
                                      decoration: const InputDecoration(
                                        hintText: "Email",
                                        hintStyle: TextStyle(color: Colors.white, fontSize: 14),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      onChanged: (value) {
                                        setState(() {});
                                      },
                                      autocorrect: false,
                                    ),
                                    const SizedBox(height: 24),
                                    TextField(
                                      controller: _passwordController,
                                      cursorColor: const Color(0xFFE4F8EF),
                                      decoration: const InputDecoration(
                                        hintText: "Senha",
                                        hintStyle: TextStyle(color: Colors.white, fontSize: 14),
                                      ),
                                      keyboardType: TextInputType.visiblePassword,
                                      onChanged: (value) {
                                        setState(() {});
                                      },
                                      obscureText: true,
                                      enableSuggestions: false,
                                      autocorrect: false,
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        _errorMessage == null
                                            ? Container()
                                            : Text(
                                                _errorMessage!,
                                                style: const TextStyle(color: Colors.red),
                                              ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 33, 142, 147),
                                        minimumSize: const Size.fromHeight(50),
                                      ),
                                      onPressed: (_emailController.text.isEmpty || _passwordController.text.isEmpty)
                                          ? null
                                          : () async {
                                              _displayProgressIndicator(_inProgress);
                                              bool isSignedIn = await AuthInterface.isSignedIn();
                                              if (!isSignedIn) {
                                                final res = await AuthInterface.signIn(
                                                    _emailController.text, _passwordController.text);

                                                if (!res["status"]) {
                                                  _dismissProgressIndicator(_inProgress);
                                                  setState(() {
                                                    _errorMessage = res["message"];
                                                  });
                                                  return;
                                                }
                                              }

                                              Future.microtask(() => Navigator.of(context).pushAndRemoveUntil(
                                                    MaterialPageRoute(builder: (context) => const DockingsWidget()),
                                                    ModalRoute.withName(""),
                                                  ));
                                              _dismissProgressIndicator(_inProgress);
                                            },
                                      child: const Text("Entrar", style: TextStyle(fontSize: 16)),
                                    ),
                                  ],
                                );

                              case NavState.recover:
                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            text: 'Entrar',
                                            style: const TextStyle(
                                              color: Colors.blue,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () => setState(() {
                                                    _navState = NavState.login;
                                                  }),
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            text: 'Já tenho o código',
                                            style: const TextStyle(
                                              color: Colors.blue,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () => setState(() {
                                                    _navState = NavState.code;
                                                  }),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _emailController,
                                      cursorColor: const Color(0xFFE4F8EF),
                                      decoration: const InputDecoration(
                                        hintText: "Email",
                                        hintStyle: TextStyle(color: Colors.white, fontSize: 14),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      autocorrect: false,
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 33, 142, 147),
                                        minimumSize: const Size.fromHeight(50),
                                      ),
                                      onPressed: () {},
                                      child: const Text("Recuperar", style: TextStyle(fontSize: 16)),
                                    ),
                                  ],
                                );

                              case NavState.code:
                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            text: 'Entrar',
                                            style: const TextStyle(
                                              color: Colors.blue,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () => setState(() {
                                                    _navState = NavState.login;
                                                  }),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _emailController,
                                      cursorColor: const Color(0xFFE4F8EF),
                                      decoration: const InputDecoration(
                                        hintText: "Email",
                                        hintStyle: TextStyle(color: Colors.white, fontSize: 14),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      autocorrect: false,
                                    ),
                                    const SizedBox(height: 24),
                                    TextField(
                                      controller: _codeController,
                                      cursorColor: const Color(0xFFE4F8EF),
                                      decoration: const InputDecoration(
                                        hintText: "Código de Recuperação",
                                        hintStyle: TextStyle(color: Colors.white, fontSize: 14),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                    const SizedBox(height: 24),
                                    TextField(
                                      controller: _newPasswordController,
                                      cursorColor: const Color(0xFFE4F8EF),
                                      decoration: const InputDecoration(
                                        hintText: "Nova senha",
                                        hintStyle: TextStyle(color: Colors.white, fontSize: 14),
                                      ),
                                      keyboardType: TextInputType.visiblePassword,
                                      obscureText: true,
                                      enableSuggestions: false,
                                      autocorrect: false,
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 33, 142, 147),
                                        minimumSize: const Size.fromHeight(50),
                                      ),
                                      onPressed: () {},
                                      child: const Text("Confirmar", style: TextStyle(fontSize: 16)),
                                    ),
                                  ],
                                );
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Ao continuar você concorda com os nossos\n',
                              ),
                              TextSpan(
                                text: 'Termos de Uso e Política de Privacidade\n',
                                style: const TextStyle(
                                  color: Colors.orange,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async => await launchUrl(
                                        Uri.parse("https://www.navalport.com/politica-de-privacidade-e-termos-de-uso"),
                                        mode: LaunchMode.externalApplication,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  _displayProgressIndicator(bool lock) {
    lock = true;
    showDialog(
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => !lock,
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
      context: context,
    );
  }

  _dismissProgressIndicator(bool lock) {
    lock = false;
    Navigator.of(context).pop();
  }
}

//todo: put eye icon in password field