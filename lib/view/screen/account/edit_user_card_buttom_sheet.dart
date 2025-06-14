import 'package:dr_ai/core/cache/cache.dart';
import 'package:dr_ai/core/utils/helper/extention.dart';
import 'package:dr_ai/core/utils/helper/scaffold_snakbar.dart';
import 'package:dr_ai/controller/account/account_cubit.dart';
import 'package:dr_ai/view/widget/button_loading_indicator.dart';
import 'package:dr_ai/view/widget/custom_button.dart';
import 'package:dr_ai/view/widget/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../core/utils/theme/color.dart';
import '../../../controller/validation/formvalidation_cubit.dart';

void showEditProfileBottomSheet(
  BuildContext context,
) {
  showModalBottomSheet(
    showDragHandle: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(22),
        topLeft: Radius.circular(22),
      ),
    ),
    backgroundColor: ColorManager.white,
    elevation: 0,
    context: context,
    isScrollControlled: true,
    builder: (_) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: BlocProvider(
          create: (context) => AccountCubit(),
          child: const BuildbuttomSheet(),
        ),
      );
    },
  );
}

class BuildbuttomSheet extends StatefulWidget {
  const BuildbuttomSheet({super.key});

  @override
  State<BuildbuttomSheet> createState() => _BuildbuttomSheetState();
}

class _BuildbuttomSheetState extends State<BuildbuttomSheet> {
  TextEditingController nameController =
      TextEditingController(text: CacheData.getdata(key: "name"));
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final validator = context.bloc<ValidationCubit>();
    final accountCubit = context.read<AccountCubit>();

    return BlocConsumer<AccountCubit, AccountState>(
      listener: (context, state) {
        if (state is ProfileUpdateLoading) {
          _isLoading = true;
        }
        if (state is ProfileUpdateSuccess) {
          customSnackBar(
              context, "Profile Updated Successfully", ColorManager.green);
          context.pop();
        }
        if (state is ProfileUpdateFailure) {
          context.pop();
          customSnackBar(context, state.message, ColorManager.error);
        }
      },
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.only(right: 16.w, left: 16.w, bottom: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: formKey,
                child: CustomTextFormField(
                  controller: nameController,
                  hintText: "Name",
                  title: " Enter Your New Name",
                  validator: validator.nameValidator,
                ),
              ),
              Gap(30.h),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      title: "Cancel",
                      onPressed: () => context.pop(),
                    ),
                  ),
                  Gap(5.w),
                  Expanded(
                    child: CustomButton(
                      widget: _isLoading == true
                          ? const ButtonLoadingIndicator()
                          : null,
                      backgroundColor: ColorManager.error,
                      title: "Update",
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (CacheData.getdata(key: "name") ==
                              nameController.text) {
                            context.pop();
                          } else {
                            accountCubit.updateUserName(
                              newName: nameController.text,
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
              Gap(10.h),
            ],
          ),
        );
      },
    );
  }
}
