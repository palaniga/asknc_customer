import 'package:flutter/material.dart';
import 'package:Asknc_user/constants/app_strings.dart';
import 'package:Asknc_user/models/category.dart';
import 'package:Asknc_user/view_models/vendor/sub_categories.vm.dart';
import 'package:Asknc_user/widgets/base.page.dart';
import 'package:Asknc_user/widgets/custom_dynamic_grid_view.dart';
import 'package:Asknc_user/widgets/list_items/category.list_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';

class SubcategoriesPage extends StatelessWidget {
  const SubcategoriesPage({
    required this.category,
    Key? key,
  }) : super(key: key);

  final Category category;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SubcategoriesViewModel>.reactive(
      viewModelBuilder: () => SubcategoriesViewModel(context, category),
      onViewModelReady: (vm) => vm.initialise(all: true),
      builder: (context, vm, child) {
        return BasePage(
          showAppBar: true,
          showCart: true,
          showLeadingAction: true,
          title: "Subcategories".tr(),
          body: CustomDynamicHeightGridView(
            noScrollPhysics: true,
            crossAxisCount: AppStrings.categoryPerRow,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            isLoading: vm.isBusy,
            itemCount: vm.subcategories.length,
            canPullUp: true,
            canRefresh: true,
            refreshController: vm.refreshController,
            onLoading: vm.loadMoreItems,
            onRefresh: () => vm.loadMoreItems(true),
            padding: EdgeInsets.all(20),
            itemBuilder: (context, index) {
              return CategoryListItem(
                category: vm.subcategories[index],
                onPressed: vm.categorySelected,
                maxLine: false,
              );
            },
          ),
        );
      },
    );
  }
}
