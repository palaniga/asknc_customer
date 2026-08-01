import 'package:Asknc_user/services/order.service.dart';
import 'package:Asknc_user/utils/ui_spacer.dart';
import 'package:Asknc_user/view_models/orders.vm.dart';
import 'package:Asknc_user/widgets/base.page.dart';
import 'package:Asknc_user/widgets/custom_list_view.dart';
import 'package:Asknc_user/widgets/list_items/order.list_item.dart';
import 'package:Asknc_user/widgets/list_items/taxi_order.list_item.dart';
import 'package:Asknc_user/widgets/states/empty.state.dart';
import 'package:Asknc_user/widgets/states/error.state.dart';
import 'package:Asknc_user/widgets/states/order.empty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../widgets/bottomsheets/contact_permission.bottomsheet.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with AutomaticKeepAliveClientMixin<OrdersPage>, WidgetsBindingObserver {
  //
  late OrdersViewModel vm;
  @override
  void initState() {
    super.initState();
    // _openContactPicker();
    WidgetsBinding.instance.addObserver(this);
  }

  void _showPermissionDeniedToast() {
    Fluttertoast.showToast(
      msg: "Permission Denied".tr(),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  Future<void> _openContactPicker() async {
    // Check and request permission using flutter_contacts
    if (!await FlutterContacts.requestPermission()) {
      // Show custom dialog before retrying permission (optional)
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => ContactPermissionDialog(),
      );

      if (result == true) {
        // Retry requesting permission
        if (!await FlutterContacts.requestPermission()) {
          _showPermissionDeniedToast();
          return;
        }
      } else {
        // User dismissed or denied
        return;
      }
    }

    try {
      // Open contact picker
      final contact = await FlutterContacts.openExternalPick();

      if (contact != null) {
        // You must fetch full contact to access phones, names, etc.
        final fullContact = await FlutterContacts.getContact(contact.id);

        if (fullContact != null && fullContact.phones.isNotEmpty) {
          setState(() {
            print(fullContact);
            print(fullContact.displayName);
            print(fullContact.phones.first.number);
            // widget.recipientNameTEC.text = fullContact.displayName;
            // widget.recipientPhoneTEC.text = fullContact.phones.first.number;
          });
        } else {
          Fluttertoast.showToast(
            msg: "No phone number found for selected contact",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
            fontSize: 14.0,
          );
        }
      }
    } catch (e) {
      print('Contact pick error: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      vm.fetchMyOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    vm = OrdersViewModel(context);
    super.build(context);
    return BasePage(
      body: SafeArea(
        child: ViewModelBuilder<OrdersViewModel>.reactive(
          viewModelBuilder: () => vm,
          onViewModelReady: (vm) => vm.initialise(),
          builder: (context, vm, child) {
            return VStack(
              [
                //

                "My Orders"
                    .tr()
                    .text
                    .xl2
                    .semiBold
                    .make()
                    .pOnly(bottom: Vx.dp10),
                //
                vm.isAuthenticated()
                    ? CustomListView(
                        canRefresh: true,
                        canPullUp: true,
                        refreshController: vm.refreshController,
                        onRefresh: vm.fetchMyOrders,
                        onLoading: () =>
                            vm.fetchMyOrders(initialLoading: false),
                        isLoading: vm.isBusy,
                        dataSet: vm.orders,
                        hasError: vm.hasError,
                        errorWidget: LoadingError(
                          onrefresh: vm.fetchMyOrders,
                        ),
                        //
                        emptyWidget: EmptyOrder(),
                        itemBuilder: (context, index) {
                          //
                          final order = vm.orders[index];
                          //for taxi tye of order
                          if (order.taxiOrder != null) {
                            return TaxiOrderListItem(
                              order: order,
                              orderPressed: () => vm.openOrderDetails(order),
                            );
                          }
                          return OrderListItem(
                            order: order,
                            orderPressed: () => vm.openOrderDetails(order),
                            onPayPressed: () =>
                                OrderService.openOrderPayment(order, vm),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            UiSpacer.verticalSpace(space: 2),
                      ).expand()
                    : EmptyState(
                        auth: true,
                        showAction: true,
                        actionPressed: vm.openLogin,
                      ).py12().centered().expand(),
              ],
            ).px20().pOnly(top: Vx.dp20);
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
