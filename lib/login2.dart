import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum NavState { login, recover, code }

class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  NavState navState = NavState.login;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

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
      body: Center(
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
                      switch (navState) {
                        case NavState.login:
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      text: 'Esqueceu a senha?',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => setState(() {
                                              navState = NavState.recover;
                                            }),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  hintText: "Email",
                                  hintStyle: TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                controller: _passwordController,
                                decoration: const InputDecoration(
                                    hintText: "Senha", hintStyle: TextStyle(color: Colors.white, fontSize: 14)),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 33, 142, 147),
                                  minimumSize: const Size.fromHeight(50),
                                ),
                                onPressed: () {},
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
                                              navState = NavState.login;
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
                                              navState = NavState.code;
                                            }),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  hintText: "Email",
                                  hintStyle: TextStyle(color: Colors.white, fontSize: 14),
                                ),
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
                                              navState = NavState.login;
                                            }),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  hintText: "Email",
                                  hintStyle: TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                controller: _codeController,
                                decoration: const InputDecoration(
                                  hintText: "Código de Recuperação",
                                  hintStyle: TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                controller: _newPasswordController,
                                decoration: const InputDecoration(
                                  hintText: "Nova senha",
                                  hintStyle: TextStyle(color: Colors.white, fontSize: 14),
                                ),
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
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Ao continuar você concorda com os nossos\n',
                        ),
                        TextSpan(
                          text: 'Termos de Uso e Política de Privacidade\n',
                          style: TextStyle(
                            color: Colors.orange,
                          ),
                          // recognizer: TapGestureRecognizer()
                          //   ..onTap = () async => await launchUrl(
                          //       Uri(path: "https://www.navalport.com/politica-de-privacidade-e-termos-de-uso/")),
                        ),
                        TextSpan(
                          text: 'www.navalport.com/politica-de-privacidade-e-termos-de-uso',
                          style: TextStyle(
                            color: Colors.orange,
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
      ),
    );
  }
}
