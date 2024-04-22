import 'package:dr_ai/core/helper/scaffold_snakbar.dart';
import 'package:dr_ai/logic/auth/sign_up/sign_up_cubit.dart';
import 'package:dr_ai/logic/validation/formvalidation_cubit.dart';
import 'package:dr_ai/view/widget/button_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:dr_ai/core/helper/extention.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../../../core/constant/image.dart';
import '../../../core/helper/custom_dialog.dart';
import '../../widget/black_button.dart';
import '../../widget/custom_button.dart';
import '../../widget/custom_drop_down_field.dart';
import '../../widget/custom_text_field.dart';
import '../../widget/custom_text_span.dart';
import '../../widget/my_stepper_form.dart';

class CreateProfile extends StatefulWidget {
  const CreateProfile({super.key});

  @override
  State<CreateProfile> createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {
  late GlobalKey<FormState> formKey;
  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
  }

  bool _isLoading = false;
  String? _name;
  String? _phoneNumber;
  String? _dob;
  String? _gender;
  String? _bloodType;
  String? _height;
  String? _weight;
  String? _chronicDiseases;
  String? _familyHistoryOfChronicDiseases;
  List<Item> genderList = const [
    Item("Male", Icons.male),
    Item("Female", Icons.female),
    Item("Other", Icons.not_interested_outlined),
  ];
  List<Item> bloodTypesList = const [
    Item('A+'),
    Item('A-'),
    Item('B+'),
    Item('B-'),
    Item('AB+'),
    Item('AB-'),
    Item('O+'),
    Item('O-'),
    Item('Unknown'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
          child: Column(
            children: [
              Gap(context.height * 0.03),
              const Backbutton(),
              Gap(context.height * 0.032),
              CustomTextSpan(
                  textOne: "Create ", textTwo: "Profile", fontSize: 24.spMin),
              Gap(8.h),
              Text(
                "Please enter your data and you can be changed it again from within the settings",
                textAlign: TextAlign.center,
                style:
                    context.textTheme.bodySmall?.copyWith(fontSize: 16.spMin),
              ),
              Gap(26.h),
              const MyStepperForm(stepReachedNumber: 2),
              _buildCreateProfileFields(),
              Gap(18.h),
              BlocConsumer<SignUpCubit, SignUpState>(
                listener: (context, state) {
                  if (state is SignUpLoading) {
                    _isLoading = true;
                  }
                  if (state is VerifyEmailSuccess) {
                    _isLoading = false;
                    FocusScope.of(context).unfocus();
                    customDialog(
                      context,
                      dismiss: false,
                      title: "Congratulation!",
                      subtitle: "Your account has been created",
                      errorMessage: "verify your email to login",
                      buttonTitle: "Login",
                      image: ImageManager.congratulationIcon,
                      widget: _isLoading == true
                          ? const ButtonLoadingIndicator()
                          : null,
                      onPressed: () =>
                          Navigator.popUntil(context, (route) => route.isFirst),
                    );
                  }
                  if (state is CreateProfileFailure) {
                    _isLoading = false;
                    customSnackBar(context, state.errorMessage);
                  }
                  if (state is VerifyEmailFailure) {
                    _isLoading = false;
                    customSnackBar(context, state.errorMessage);
                  }
                  if (state is CreateProfileFailure) {
                    _isLoading = false;
                    customSnackBar(context, state.errorMessage);
                  }
                },
                builder: (context, state) {
                  final cubit = context.bloc<SignUpCubit>();
                  return CustomButton(
                    widget: _isLoading == true
                        ? const ButtonLoadingIndicator()
                        : null,
                    title: "Submit",
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        await cubit.createPassword();
                        await cubit.createProfile(
                          name: _name!,
                          phoneNumber: _phoneNumber!,
                          dob: _dob!,
                          gender: _gender!,
                          bloodType: _bloodType!,
                          height: _height!,
                          weight: _weight!,
                          chronicDiseases: _chronicDiseases!,
                          familyHistoryOfChronicDiseases:
                              _familyHistoryOfChronicDiseases!,
                        );
                        await cubit.verifyEmail();
                      }
                    },
                  );
                },
              ),
              Gap(18.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateProfileFields() {
    final cubit = context.bloc<FormvalidationCubit>();
    return Form(
      key: formKey,
      child: Column(
        children: [
          CustomTextFormField(
            keyboardType: TextInputType.name,
            title: "Name",
            hintText: "Enter your Name",
            onSaved: (data) {
              _name = data;
            },
            validator: cubit.nameValidator,
          ),
          CustomTextFormField(
            keyboardType: TextInputType.phone,
            title: "phone Number",
            hintText: "Enter your phone Number",
            onSaved: (data) {
              _phoneNumber = data!;
            },
            validator: cubit.phoneNumberValidator,
          ),
          CustomTextFormField(
            keyboardType: TextInputType.datetime,
            title: "Date of birth",
            hintText: "Enter your Date of birth",
            onSaved: (data) {
              _dob = data;
            },
            validator: cubit.validateDateOfBirth,
          ),
          CustomDropDownField(
            hintText: "Enter your Gender",
            title: "Gender",
            items: genderList,
            onSaved: (data) {
              _gender = data!.name.toString();
            },
          ),
          CustomDropDownField(
              hintText: "Enter your Blood Type",
              title: "Blood Type",
              items: bloodTypesList,
              onSaved: (data) {
                _bloodType = data!.name.toString();
              }),
          CustomTextFormField(
            keyboardType: TextInputType.number,
            title: "Height ( CM )",
            hintText: "Enter your height",
            onSaved: (data) {
              _height = data!;
            },
            validator: cubit.heightValidator,
          ),
          CustomTextFormField(
            keyboardType: TextInputType.number,
            title: "Weight ( KG )",
            hintText: "Enter your weight",
            onSaved: (data) {
              _weight = data!;
            },
            validator: cubit.weightValidator,
          ),
          CustomTextFormField(
            keyboardType: TextInputType.name,
            title: "chronic diseases",
            hintText: "Enter your chronic diseases",
            onSaved: (data) {
              _chronicDiseases = data;
            },
          ),
          CustomTextFormField(
            keyboardType: TextInputType.name,
            title: "Family history of chronic diseases",
            hintText: "Enter your Family history of chronic diseases",
            onSaved: (data) {
              _familyHistoryOfChronicDiseases = data;
            },
          ),
        ],
      ),
    );
  }
}
