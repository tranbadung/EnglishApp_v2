import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speak_up/data/providers/app_navigator_provider.dart';
import 'package:speak_up/domain/use_cases/authentication/sign_in_with_email_and_password_use_case.dart';
import 'package:speak_up/injection/injector.dart';
import 'package:speak_up/presentation/navigation/app_routes.dart';
import 'package:speak_up/presentation/pages/sign_in_email/sign_in_email_state.dart';
import 'package:speak_up/presentation/pages/sign_in_email/sign_in_email_view_model.dart';
import 'package:speak_up/presentation/resources/app_images.dart';
import 'package:speak_up/presentation/utilities/enums/loading_status.dart';
import 'package:speak_up/presentation/utilities/enums/validator_type.dart';
import 'package:speak_up/presentation/utilities/error/app_error_message.dart';
import 'package:speak_up/presentation/widgets/buttons/app_back_button.dart';
import 'package:speak_up/presentation/widgets/buttons/custom_button.dart';
import 'package:speak_up/presentation/widgets/loading_indicator/app_loading_indicator.dart';
import 'package:speak_up/presentation/widgets/text_fields/custom_text_field.dart';

final signInEmailViewModelProvider =
StateNotifierProvider.autoDispose<SignInEmailViewModel, SignInEmailState>(
        (ref) => SignInEmailViewModel(
      injector.get<SignInWithEmailAndPasswordUseCase>(),
    ));

class SignInEmailView extends ConsumerStatefulWidget {
  const SignInEmailView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SignInEmailViewState();
}

class _SignInEmailViewState extends ConsumerState<SignInEmailView> {
  final _formKey = GlobalKey<FormState>();
  final _emailTextEditingController = TextEditingController();
  final _passwordTextEditingController = TextEditingController();

  @override
  void dispose() {
    _emailTextEditingController.dispose();
    _passwordTextEditingController.dispose();
    super.dispose();
  }

  void addFetchDataListener() {
    ref.listen(
        signInEmailViewModelProvider.select((value) => value.loadingStatus),
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
  }

  void addErrorMessageListener(BuildContext context) {
    ref.listen(signInEmailViewModelProvider.select((value) => value.errorCode),
            (previous, next) {
          if (next.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(getAppErrorMessage(next, context)),
                backgroundColor: Colors.red,
              ),
            );
          }
          ref.read(signInEmailViewModelProvider.notifier).resetError();
        });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signInEmailViewModelProvider);
    addFetchDataListener();
    addErrorMessageListener(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: const AppBackButton(),
        elevation: 2,
        backgroundColor: Colors.white,
        shadowColor: Colors.grey.shade200,
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: AppImages.signInEmail(
                        width: kIsWeb
                            ? ScreenUtil().screenWidth * 0.25
                            : ScreenUtil().screenWidth * 0.93,
                        boxFit: BoxFit.fitWidth,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 30),
                          child: Text(
                            AppLocalizations.of(context)!.signInWithYourEmail,
                            style: TextStyle(
                              fontSize: kIsWeb
                                  ? ScreenUtil().setSp(20)
                                  : ScreenUtil().setSp(24),
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    CustomTextField(
                      aboveText: AppLocalizations.of(context)!.emailAddress,
                      hintText: AppLocalizations.of(context)!.enterYourEmail,
                      suffixIcon: const Icon(Icons.email, color: Colors.blue),
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailTextEditingController,
                      validatorType: ValidatorType.email,
                      context: context,
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      aboveText: AppLocalizations.of(context)!.password,
                      hintText: AppLocalizations.of(context)!.enterYourPassword,
                      keyboardType: TextInputType.visiblePassword,
                      controller: _passwordTextEditingController,
                      errorMaxLines: 2,
                      validatorType: ValidatorType.password,
                      context: context,
                      obscureText: !state.isPasswordVisible,
                      onSuffixIconTap: () {
                        ref
                            .read(signInEmailViewModelProvider.notifier)
                            .onPasswordVisibilityPressed();
                      },
                      suffixIcon: Icon(
                        state.isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 30.h),
                    CustomButton(
                      marginVertical: 16,
                      text: AppLocalizations.of(context)!.signIn,
                      buttonState: state.loadingStatus.buttonState,
                      onTap: () {
                        if (!_formKey.currentState!.validate()) return;
                        ref
                            .read(signInEmailViewModelProvider.notifier)
                            .onSignInButtonPressed(
                            _emailTextEditingController.text,
                            _passwordTextEditingController.text);
                      },
                      height: 56.h,
                      width: 200.w,
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.lightBlueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: 30.r,
                      shadowColor: Colors.blue.shade200,
                    ),
                    SizedBox(height: 32.h),
                    Text(
                      AppLocalizations.of(context)!.dontHaveAnAccount,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(appNavigatorProvider).navigateTo(
                          AppRoutes.signUpEmail,
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.signUp,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (state.loadingStatus == LoadingStatus.success)
            const AppLoadingIndicator(),
        ],
      ),
    );
  }
}
