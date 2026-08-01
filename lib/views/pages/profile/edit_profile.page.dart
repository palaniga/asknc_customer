import 'package:cached_network_image/cached_network_image.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:Asknc_user/constants/app_images.dart';
import 'package:Asknc_user/services/validator.service.dart';
import 'package:Asknc_user/utils/ui_spacer.dart';
import 'package:Asknc_user/view_models/edit_profile.vm.dart';
import 'package:Asknc_user/widgets/base.page.dart';
import 'package:Asknc_user/widgets/busy_indicator.dart';
import 'package:Asknc_user/widgets/buttons/custom_button.dart';
import 'package:Asknc_user/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EditProfileViewModel>.reactive(
      viewModelBuilder: () => EditProfileViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          raiseinset: true,
          showLeadingAction: true,
          showAppBar: true,

          title: "Edit Profile".tr(),
          body: SafeArea(
              top: true,
              bottom: false,
              child:
                  //
                  SingleChildScrollView(
                    child: VStack(
                   [
                    //
                    Stack(
                      children: [
                        //
                        model.currentUser == null
                            ? BusyIndicator()
                            : model.newPhoto == null
                                ? CachedNetworkImage(
                                    imageUrl: model.currentUser?.photo ?? "",
                                    progressIndicatorBuilder:
                                        (context, url, progress) {
                                      return BusyIndicator();
                                    },
                                    errorWidget: (context, imageUrl, progress) {
                                      return Image.asset(
                                        AppImages.user,
                                      );
                                    },
                                    fit: BoxFit.cover,
                                  )
                                    .wh(
                                      Vx.dp64 * 1.3,
                                      Vx.dp64 * 1.3,
                                    )
                                    .box
                                    .rounded
                                    .clip(Clip.antiAlias)
                                    .make()
                                : Image.file(
                                    model.newPhoto!,
                                    fit: BoxFit.cover,
                                  )
                                    .wh(
                                      Vx.dp64 * 1.3,
                                      Vx.dp64 * 1.3,
                                    )
                                    .box
                                    .rounded
                                    .clip(Clip.antiAlias)
                                    .make(),

                        //
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Icon(
                            FlutterIcons.camera_ant,
                            size: 16,
                          )
                              .p8()
                              .box
                              .color(context.theme.colorScheme.background)
                              .roundedFull
                              .shadow
                              .make()
                              .onInkTap(model.changePhoto),
                        ),
                      ],
                    ).box.makeCentered(),

                    //form
                    Form(
                      key: model.formKey,
                      child: VStack(
                        [
                          //
                          CustomTextFormField(
                            labelText: "Name".tr(),
                            textEditingController: model.nameTEC,
                            validator: FormValidator.validateName,
                          ).py12(),
                          //
                          CustomTextFormField(
                            labelText: "Email".tr(),
                            keyboardType: TextInputType.emailAddress,
                            textEditingController: model.emailTEC,
                            validator: FormValidator.validateEmail,
                          ).py12(),
                          //
                          CustomTextFormField(
                            prefixIcon: HStack(
                              [
                                //icon/flag
                                Flag.fromString(
                                  model.selectedCountry?.countryCode ?? "in",
                                  width: 20,
                                  height: 20,
                                ),
                                UiSpacer.horizontalSpace(space: 5),
                                //text
                                ("+" + (model.selectedCountry?.phoneCode ?? "1"))
                                    .text
                                    .make(),
                              ],
                            ).px8().onInkTap(model.showCountryDialPicker),
                            labelText: "Phone",
                            keyboardType: TextInputType.phone,
                            textEditingController: model.phoneTEC,
                            validator: FormValidator.validatePhone,
                          ).py12(),

                          "Account Details".tr().text.lg.bold.make().py8(),
                          //
                          CustomTextFormField(
                            labelText: "Account No",
                            textEditingController: model.accountNO,
                          ).py12(),

                          CustomTextFormField(
                            labelText: "Account Name",
                            textEditingController: model.accountNAME,
                          ).py12(),



                          CustomTextFormField(
                            labelText: "Bank Name",
                            textEditingController: model.bankNAME,
                          ).py12(),
                          CustomTextFormField(
                            labelText: "IFSC CODE",
                            textEditingController: model.accountIFSC,
                          ).py12(),
                          // CustomTextFormField(
                          //   labelText: "Branch",
                          //   textEditingController: model.bankBRANCH,
                          //   validator: FormValidator.validateName,
                          // ).py12(),
                          CustomButton(
                            title: "Update Profile".tr(),
                            loading: model.isBusy,
                            onPressed: model.processUpdate,
                          ).centered().py12(),
                        ],
                      ),
                    ).py20(),
                ],
              ).p20().scrollVertical(),
                  )),
        );
      },
    );
  }
}
