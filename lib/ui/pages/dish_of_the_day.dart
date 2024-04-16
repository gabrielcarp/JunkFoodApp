import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:userapp/data/dish_repository.dart';
import 'package:userapp/dish_of_the_day_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:userapp/ui/controllers/dish_of_the_day_controller.dart';
import 'package:userapp/ui/widgets/dish_display_widget.dart';
import 'package:userapp/ui/widgets/language_dropdown_widget.dart';
import 'package:userapp/ui/widgets/no_dish_widget.dart';

class DishOfTheDay extends ConsumerWidget {
  const DishOfTheDay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.dishOfTheDay),
        actions: [LanguageDropdown()],
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
              .read(dishOfTheDayControllerProvider.notifier)
              .refetchDishOfTheDay();
        },
        child: ListView(
          children: [
            Center(
                child: switch (ref.watch(dishOfTheDayControllerProvider)) {
              AsyncData(:final value) => value.isNotEmpty
                  ? DishDisplayWidget(dishes: value)
                  : const NoDishWidget(),
              AsyncError(:final error) => Text(error.toString()),
              _ => const CircularProgressIndicator()
            }),
          ],
        ),
      ),
    );
  }
}
