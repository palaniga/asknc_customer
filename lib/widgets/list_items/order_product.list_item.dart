import 'package:flutter/material.dart';
import 'package:Asknc_user/extensions/dynamic.dart';
import 'package:Asknc_user/extensions/string.dart';
import 'package:Asknc_user/models/order.dart';
import 'package:Asknc_user/models/order_product.dart';
import 'package:Asknc_user/constants/app_strings.dart';
import 'package:Asknc_user/utils/ui_spacer.dart';
import 'package:Asknc_user/views/pages/order/widgets/order_digitial_product_download.dart';
import 'package:Asknc_user/widgets/bottomsheets/order_product_action.bottomsheet.dart';
import 'package:Asknc_user/widgets/buttons/arrow_indicator.dart';
import 'package:Asknc_user/widgets/cards/custom.visibility.dart';
import 'package:Asknc_user/widgets/cards/rounded_container.dart';
import 'package:Asknc_user/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderProductListItem extends StatelessWidget {
  const OrderProductListItem({
    required this.orderProduct,
    required this.order,
    Key? key,
  }) : super(key: key);

  final OrderProduct orderProduct;
  final Order order;
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //other status
        CustomVisibilty(
          visible: !order.isCommerce,
          child: HStack(
            [
              RoundedContainer(
                child: CustomImage(
                  imageUrl: orderProduct.product!.photo,
                  width: 50,
                  height: 50,
                ),
              ),

              VStack(
                [
                  //
                  "${orderProduct.product!.name}".text.make(),
                  Visibility(
                    visible: orderProduct.options != null,
                    child:
                        "${orderProduct.options}".text.sm.gray500.medium.make(),
                  ),
                  //
                  5.heightBox,
                  //qty
                  "x ${orderProduct.quantity}".text.bold.make(),
                ],
              ).px12().expand(),
              "${AppStrings.currencySymbol}${orderProduct.price}"
                  .currencyFormat()
                  .text
                  .semiBold
                  .make(),
              //
            ],
          ),
        ),

        //completed order
        CustomVisibilty(
          visible: order.isCommerce,
          child: VStack(
            [
              HStack(
                [
                  //
                  RoundedContainer(
                    child: CustomImage(
                      imageUrl: orderProduct.product!.photo,
                      width: 60,
                      height: 60,
                    ),
                  ),

                  VStack(
                    [
                      //
                      orderProduct.product!.name.text
                          .maxLines(2)
                          .ellipsis
                          .light
                          .make(),
                      orderProduct.options.isNotEmptyAndNotNull
                          ? orderProduct.options!.text.sm.gray500.medium.make()
                          : UiSpacer.emptySpace(),

                      HStack(
                        [
                          //qty
                          "Qty: %s"
                              .tr()
                              .fill([orderProduct.quantity])
                              .text
                              .semiBold
                              .make(),
                          //
                          UiSpacer.hSpace(15),
                          //price
                          "Price: %s"
                              .tr()
                              .fill(
                                [
                                  "${AppStrings.currencySymbol}${orderProduct.price}"
                                      .currencyFormat()
                                ],
                              )
                              .text
                              .semiBold
                              .make(),
                        ],
                      ),
                    ],
                  ).px12().expand(),
                  //
                  UiSpacer.hSpace(6),
                  ArrowIndicator(26),
                  //
                ],
              ),
              UiSpacer.divider().py8(),
              //digital download
              DigitialProductOrderDownload(order, orderProduct),
            ],
          ).onInkTap(
            () {
              //show bottomsheet
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                backgroundColor: Colors.transparent,
                builder: (ctx) {
                  return OrderProductActionBottomSheet(orderProduct);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
