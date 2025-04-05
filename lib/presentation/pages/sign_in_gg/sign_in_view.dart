import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speak_up/data/providers/app_navigator_provider.dart';
import 'package:speak_up/domain/use_cases/authentication/sign_in_with_google_use_case.dart';
import 'package:speak_up/domain/use_cases/firestore/save_user_data_use_case.dart';
import 'package:speak_up/injection/injector.dart';
import 'package:speak_up/presentation/navigation/app_routes.dart';
import 'package:speak_up/presentation/pages/sign_in_email/resetPass.dart';
import 'package:speak_up/presentation/pages/sign_in_gg/sign_in_state.dart';
import 'package:speak_up/presentation/pages/sign_in_gg/sign_in_view_model.dart';
import 'package:speak_up/presentation/resources/app_images.dart';
import 'package:speak_up/presentation/utilities/enums/loading_status.dart';
import 'package:speak_up/presentation/utilities/error/app_error_message.dart';
import 'package:speak_up/presentation/widgets/buttons/app_back_button.dart';
import 'package:speak_up/presentation/widgets/buttons/custom_button.dart';
import 'package:speak_up/presentation/widgets/loading_indicator/app_loading_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../main.dart';

final signInViewModelProvider =
StateNotifierProvider.autoDispose<SignInViewModel, SignInState>(
        (ref) => SignInViewModel(
      injector.get<SignInWithGoogleUseCase>(),
      injector.get<SaveUserDataUseCase>(),
    ));

class SignInView extends ConsumerStatefulWidget {
  const SignInView({super.key});

  @override
  ConsumerState<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends ConsumerState<SignInView> {
  String email = '';
  bool isResetPasswordVisible = false;

  Future<void> _resetPassword(BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "reset password email sent",
            ),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          isResetPasswordVisible = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getAppErrorMessage(e.toString(), context)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signInViewModelProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.welcome,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                AppImages.signIn(),
                const SizedBox(height: 24),
                CustomButton(
                  text: AppLocalizations.of(context)!.continueWithGoogle,
                  height: 50,
                  textColor: Colors.black,
                  fontWeight: FontWeight.w600,
                  image: AppImages.googleLogo(),
                  buttonColor: const Color(0xFFEBECEE),
                  onTap: () {
                    ref
                        .read(signInViewModelProvider.notifier)
                        .signInWithGoogle();
                  },
                ),
                const SizedBox(height: 8),
                CustomButton(
                  text: AppLocalizations.of(context)!.signInWithYourEmail,
                  height: 50,
                  textColor: Colors.white,
                  fontWeight: FontWeight.w600,
                  image: const Icon(
                    Icons.email_outlined,
                    color: Colors.white,
                  ),
                  onTap: () {
                    ref.read(appNavigatorProvider).navigateTo(
                      AppRoutes.signInEmail,
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.dontHaveAnAccount,
                  style: const TextStyle(fontSize: 14),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(appNavigatorProvider).navigateTo(
                      AppRoutes.signUpEmail,
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context)!.signUp,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ResetPasswordView(),
                      ),
                    );
                  },
                  child: Text(
                    "Forgot Password",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
