import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speak_up/data/providers/app_navigator_provider.dart';
import 'package:speak_up/domain/use_cases/authentication/sign_in_with_google_use_case.dart';
import 'package:speak_up/domain/use_cases/firestore/save_user_data_use_case.dart';
import 'package:speak_up/injection/injector.dart';
import 'package:speak_up/presentation/navigation/app_routes.dart';
import 'package:speak_up/presentation/pages/sign_in_gg/sign_in_state.dart';
import 'package:speak_up/presentation/pages/sign_in_gg/sign_in_view_model.dart';
import 'package:speak_up/presentation/resources/app_images.dart';
import 'package:speak_up/presentation/utilities/enums/loading_status.dart';
import 'package:speak_up/presentation/utilities/error/app_error_message.dart';
import 'package:speak_up/presentation/widgets/buttons/app_back_button.dart';
import 'package:speak_up/presentation/widgets/buttons/custom_button.dart';
import 'package:speak_up/presentation/widgets/loading_indicator/app_loading_indicator.dart';

final signInViewModelProvider =
    StateNotifierProvider.autoDispose<SignInViewModel, SignInState>(
        (ref) => SignInViewModel(
              injector.get<SignInWithGoogleUseCase>(),
              injector.get<SaveUserDataUseCase>(),
            ));

class SignInView extends ConsumerWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signInViewModelProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    ref.listen(signInViewModelProvider.select((value) => value.loadingStatus),
        (previous, next) {
      if (next == LoadingStatus.success) {
        Future.delayed(const Duration(seconds: 1), () {
          ref.read(appNavigatorProvider).navigateTo(
                AppRoutes.mainMenu,
                shouldClearStack: true,
              );
        });
      }
    });
    ref.listen(signInViewModelProvider.select((value) => value.errorCode),
        (previous, next) {
      if (next.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getAppErrorMessage(next, context)),
            backgroundColor: Colors.red,
          ),
        );
      }
      ref.read(signInViewModelProvider.notifier).resetError();
    });

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
      ),
      body: Center(
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
              SizedBox(height: 16),
              AppImages.signIn(),
              SizedBox(height: 24),
              CustomButton(
                text: AppLocalizations.of(context)!.continueWithGoogle,
                height: 50,
                textColor: Colors.black,
                fontWeight: FontWeight.w600,
                image: AppImages.googleLogo(),
                buttonColor: const Color(0xFFEBECEE),
                onTap: () {
                  ref.read(signInViewModelProvider.notifier).signInWithGoogle();
                },
              ),
              SizedBox(height: 8),
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
              SizedBox(height: 16),
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
            ],
          ),
        ),
      ),
    );
  }
}
