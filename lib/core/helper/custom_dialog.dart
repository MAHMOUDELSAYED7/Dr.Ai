import 'package:dr_ai/core/constant/color.dart';
import 'package:dr_ai/core/helper/extention.dart';
import 'package:dr_ai/logic/validation/formvalidation_cubit.dart';
import 'package:dr_ai/view/widget/button_loading_indicator.dart';
import 'package:dr_ai/view/widget/custom_button.dart';
import 'package:dr_ai/view/widget/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

import '../../logic/account/account_cubit.dart';
import '../constant/image.dart';
import '../constant/routes.dart';
import 'scaffold_snakbar.dart';

void alertMessage(BuildContext context, {String? message}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Icon(Icons.warning_amber),
      content: Text(message ?? "there was an error please try again later!"),
    ),
  );
}

void customDialog(BuildContext context,
    {required String title,
    required String subtitle,
    required String buttonTitle,
    required VoidCallback onPressed,
    required String image,
    String? errorMessage,
    Color? secondButtoncolor,
    Widget? widget,
    bool? dismiss}) {
  showDialog(
      context: context,
      barrierDismissible: dismiss ?? true,
      builder: (_) => CustomDialog(
            title: title,
            subtitle: subtitle,
            buttonTitle: buttonTitle,
            onPressed: onPressed,
            image: image,
            errorMessage: errorMessage,
            secondButtoncolor: secondButtoncolor,
            widget: widget,
          ));
}

class CustomDialog extends StatefulWidget {
  const CustomDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonTitle,
    required this.onPressed,
    required this.image,
    this.errorMessage,
    this.secondButtoncolor,
    this.widget,
  });
  final String title;
  final String subtitle;
  final String? errorMessage;
  final String buttonTitle;
  final VoidCallback onPressed;
  final Color? secondButtoncolor;
  final Widget? widget;
  final String image;

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  bool _islogoutLoading = false;
  bool _isDeleteAccountLoading = false;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: REdgeInsets.all(16.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.dm),
      ),
      elevation: 0,
      backgroundColor: ColorManager.white,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return BlocConsumer<AccountCubit, AccountState>(
      listener: (context, state) {
        if (state is AccountLogoutLoading) {
          _islogoutLoading = true;
        }

        if (state is AccountLogoutSuccess) {
          _islogoutLoading = false;
          Navigator.pushNamedAndRemoveUntil(
              context, RouteManager.login, (route) => false);
          customSnackBar(context, state.message, ColorManager.error);
        }
        if (state is AccountDeleteLoading) {
          _isDeleteAccountLoading = true;
        }
        if (state is AccountDeleteSuccess) {
          _isDeleteAccountLoading = false;

          Navigator.pushNamedAndRemoveUntil(
              context, RouteManager.login, (route) => false);

          customSnackBar(context, state.message, ColorManager.error);
        }
        if (state is AccountDeleteFailure) {
          _isDeleteAccountLoading = false;
          context.pop();
          customSnackBar(context, state.message, ColorManager.error);
        }
      },
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: ColorManager.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(12.dm),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                widget.image,
                width: 125.w,
                height: 125.w,
              ),
              Gap(18.h),
              Text(widget.title,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyLarge?.copyWith(
                      color: widget.secondButtoncolor, fontSize: 18.spMin)),
              Gap(8.h),
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall,
              ),
              (widget.errorMessage != null)
                  ? Text(
                      widget.errorMessage!,
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: ColorManager.error,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : const SizedBox(),
              Gap(22.h),
              widget.secondButtoncolor != null
                  ? Column(
                      children: [
                        CustomButton(
                          title: "Cancel",
                          onPressed: () => context.pop(),
                        ),
                        Gap(13.h),
                        CustomButton(
                          widget: (_islogoutLoading == true ||
                                  _isDeleteAccountLoading == true)
                              ? const ButtonLoadingIndicator()
                              : null,
                          backgroundColor: widget.secondButtoncolor,
                          title: widget.buttonTitle,
                          onPressed: widget.onPressed,
                        ),
                      ],
                    )
                  : CustomButton(
                      widget: widget.widget,
                      title: widget.buttonTitle,
                      onPressed: widget.onPressed,
                    ),
            ],
          ),
        );
      },
    );
  }
}

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  late GlobalKey<FormState> _formKey;
  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    super.initState();
  }

  String? _password;
  bool _isLoading = false;
  String? errorMessage;
  @override
  Widget build(BuildContext context) {
    final cubit = context.bloc<AccountCubit>();
    return BlocConsumer<AccountCubit, AccountState>(
      listener: (context, state) {
        if (state is AccountReAuthLoading) {
          errorMessage = null;
          _isLoading = true;
        }
        if (state is AccountReAuthSuccess) {
          _isLoading = false;
          context.pop();
          customDialog(context,
              secondButtoncolor: ColorManager.error,
              title: "Delete Account?!",
              subtitle: "Are you sure you want to delete your account?",
              buttonTitle: "Delete",
              image: ImageManager.errorIcon,
              onPressed: () => cubit.deleteAccount());
        }
        if (state is AccountReAuthFailure) {
          _isLoading = false;
          errorMessage = state.message;
        }
      },
      builder: (context, state) {
        return Center(
          child: SingleChildScrollView(
            child: Dialog(
              insetPadding: REdgeInsets.all(16.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.dm),
              ),
              elevation: 0,
              backgroundColor: ColorManager.white,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: ColorManager.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(12.dm),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      ImageManager.errorIcon,
                      width: 125.w,
                      height: 125.w,
                    ),
                    Gap(18.h),
                    Text("Delete Account?!",
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyLarge?.copyWith(
                            color: ColorManager.error, fontSize: 18.spMin)),
                    Gap(8.h),
                    Text(
                      "Enter your password to delete your account",
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodySmall,
                    ),
                    Gap(errorMessage != null ? 8.h : 0),
                    if (errorMessage != null)
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium
                            ?.copyWith(color: ColorManager.error),
                      ),
                    Form(
                      key: _formKey,
                      child: CustomTextFormField(
                        obscureText: true,
                        isVisible: true,
                        title: "Password",
                        onSaved: (data) => _password = data,
                        validator: context
                            .bloc<FormvalidationCubit>()
                            .validatePassword,
                      ),
                    ),
                    Gap(22.h),
                    CustomButton(
                      isDisabled: _isLoading,
                      widget:
                          _isLoading ? const ButtonLoadingIndicator() : null,
                      title: "Next",
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _formKey.currentState?.save();
                          cubit.reAuthenticateUser(_password!);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class LoginDialog extends StatelessWidget {
  const LoginDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
        insetPadding: REdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.dm),
        ),
        elevation: 0,
        backgroundColor: ColorManager.white,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: ColorManager.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(12.dm),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    ImageManager.curvedLines,
                    width: 135.w,
                    height: 135.w,
                  ),
                  SvgPicture.asset(
                    ImageManager.congratulationIcon,
                    width: 125.w,
                    height: 125.w,
                  ),
                ],
              ),
              Gap(18.h),
              Text(
                "Congratulation!",
                style: context.textTheme.bodyLarge
                    ?.copyWith(fontSize: 18.spMin, height: 0.9.h),
              ),
              SvgPicture.asset(
                ImageManager.underLine,
                height: 6.h,
                width: context.width / 3,
              ),
              Gap(8.h),
              Text(
                "Your account has been created",
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall,
              ),
              Gap(3.h),
              Text(
                "Please verify your email to login.",
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(
                  color: ColorManager.error,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Gap(22.h),
              CustomButton(
                title: "Login",
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
              ),
            ],
          ),
        ));
  }
}

class ChangePasswordDialog extends StatelessWidget {
  const ChangePasswordDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        insetPadding: REdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.dm),
        ),
        elevation: 0,
        backgroundColor: ColorManager.white,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: ColorManager.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(12.dm),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                ImageManager.trueIcon,
                width: 125.w,
                height: 125.w,
              ),
              Gap(18.h),
              Text(
                "Congratulation!",
                style:
                    context.textTheme.bodyLarge?.copyWith(fontSize: 18.spMin),
              ),
              Gap(8.h),
              Text(
                "your password has been changed",
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall,
              ),
              Gap(3.h),
              Text(
                "Try to keep the password away to avoid theft of your account and data",
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(
                  color: ColorManager.error,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Gap(22.h),
              CustomButton(
                title: "Continue",
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
              ),
            ],
          ),
        ));
  }
}
