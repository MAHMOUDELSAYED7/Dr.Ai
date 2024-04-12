import 'package:dr_ai/logic/validation/formvalidation_cubit.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:dr_ai/core/helper/extention.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../../../core/constant/routes.dart';
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

  String? _name;
  int? _phoneNumber;
  String? _dob;
  String? _gender;
  String? _bloodType;
  double? _height;
  double? _weight;
  String? _chronicDiseases;
  String? _familyHistoryOfChronicDiseases;
  List<Item> genderList = const [
    Item("Male"),
    Item("Female"),
    Item("Other"),
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
              CustomButton(
                title: "Submit",
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    log("Sccess");
                    log("$_name $_phoneNumber $_dob $_gender $_bloodType $_height $_weight $_chronicDiseases $_familyHistoryOfChronicDiseases");
                    Navigator.pushNamed(context, RouteManager.information);
                  }
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
            validator: (value) => cubit.nameValidator(value),
          ),
          CustomTextFormField(
            keyboardType: TextInputType.phone,
            title: "phone Number",
            hintText: "Enter your phone Number",
            onSaved: (data) {
              _phoneNumber = int.parse(data!);
            },
            validator: (value) => cubit.phoneNumberValidator(value),
          ),
          CustomTextFormField(
            keyboardType: TextInputType.number,
            title: "Date of birth",
            hintText: "Enter your Date of birth",
            onSaved: (data) {
              _dob = data;
            },
            validator: (value) => cubit.validateDateOfBirth(value),
          ),
          CustomDropDownField(
            hintText: "Enter your Gender",
            title: "Gender",
            items: genderList,
            onSaved: (data) {
              _gender = data.toString();
            },
          ),
          CustomDropDownField(
              hintText: "Enter your Blood Type",
              title: "Blood Type",
              items: bloodTypesList,
              onSaved: (data) {
                _bloodType = data.toString();
              }),
          CustomTextFormField(
            keyboardType: TextInputType.number,
            title: "Height ( CM )",
            hintText: "Enter your height",
            onSaved: (data) {
              _height = double.parse(data!);
            },
            validator: (value) => cubit.heightValidator(value),
          ),
          CustomTextFormField(
            keyboardType: TextInputType.number,
            title: "Weight ( KG )",
            hintText: "Enter your weight",
            onSaved: (data) {
              _weight = double.parse(data!);
            },
            validator: (value) => cubit.weightValidator(value),
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
