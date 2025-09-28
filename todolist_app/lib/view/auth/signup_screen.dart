import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_application/secure_application.dart';
import 'package:todolist_app/view/auth/signin_screen.dart';
import 'package:todolist_app/viewmodel/auth/auth_viewmodel.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    SecureApplicationProvider.of(context, listen: false)!.secure();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create an Account',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                      labelText: 'Username', border: OutlineInputBorder()),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a username' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                      labelText: 'Email', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter an email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                      labelText: 'Password', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a password' : null,
                ),
                const SizedBox(height: 24),
                Consumer<AuthViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.state == AuthState.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          viewModel.signUp(
                            username: usernameController.text,
                            email: emailController.text,
                            password: passwordController.text,
                          );
                        }
                      },
                      child: const Text('Sign Up'),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Listener para mostrar mensajes (éxito o error)
                Consumer<AuthViewModel>(
                  builder: (context, viewModel, child) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (viewModel.state == AuthState.error &&
                          viewModel.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(viewModel.errorMessage!),
                              backgroundColor: Colors.red),
                        );
                        viewModel.resetState(); // Limpiamos el error
                      } else if (viewModel.state == AuthState.success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Account created! Please sign in.'),
                              backgroundColor: Colors.green),
                        );
                        // Desbloqueamos ANTES de navegar a la pantalla no segura.
                        SecureApplicationProvider.of(context, listen: false)!.open();
                        viewModel.resetState(); // Limpiamos el estado
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const SignInScreen()),
                        );
                      }
                    });
                    return const SizedBox.shrink(); // No dibuja nada
                  },
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Provider.of<AuthViewModel>(context, listen: false).resetState();
                    // Desbloqueamos ANTES de navegar a la pantalla no segura.
                    SecureApplicationProvider.of(context, listen: false)!.open();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SignInScreen()));
                  },
                  child: const Text('Already have an account? Sign In'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    SecureApplicationProvider.of(context, listen: false)!.open();
    super.dispose();
  }
}