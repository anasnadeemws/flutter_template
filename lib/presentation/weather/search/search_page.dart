import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_template/presentation/base/widgets/list/ui_list.dart';
import 'package:flutter_template/presentation/base/widgets/page/base_page.dart';
import 'package:flutter_template/presentation/entity/screen/screen.dart';
import 'package:flutter_template/presentation/entity/weather/ui_city.dart';
import 'package:flutter_template/presentation/intl/strings.dart';
import 'package:flutter_template/presentation/weather/search/list/ui_city_renderer.dart';
import 'package:flutter_template/presentation/weather/search/search_screen_intent.dart';
import 'package:flutter_template/presentation/weather/search/search_screen_state.dart';
import 'package:flutter_template/presentation/weather/search/search_view_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tuple/tuple.dart';

class SearchPage extends StatelessWidget {
  final SearchScreen searchScreen;

  const SearchPage({Key? key, required this.searchScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage<SearchScreen, SearchScreenState, SearchViewModel>(
      hideDefaultLoading: true,
      viewModelProvider: searchViewModelProvider,
      screen: searchScreen,
      onAppBarBackPressed: (viewModel) => viewModel.onIntent(
        SearchScreenIntent.back(),
      ),
      body: const _SearchPageBody(),
    );
  }
}

class _SearchPageBody extends ConsumerWidget {
  const _SearchPageBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();

    textController.addListener(() {
      final viewModel = ref.read(searchViewModelProvider.notifier);
      viewModel.onIntent(SearchScreenIntent.search(
        searchTerm: textController.text,
      ));
    });

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Flex(
        direction: Axis.vertical,
        children: [
          TextField(
            controller: textController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: Strings.startTypingToSearch.tr(),
            ),
          ),
          const _SearchPageResults(),
        ],
      ),
    );
  }
}

class _SearchPageResults extends ConsumerWidget {
  const _SearchPageResults({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(searchViewModelProvider.notifier);
    final loadingToSearchListPair = ref.watch(searchViewModelProvider
        .select((value) => Tuple2(value.showLoading, value.searchList)));

    final showLoading = loadingToSearchListPair.item1;
    final searchList = loadingToSearchListPair.item2;

    if (!showLoading && searchList.isEmpty) {
      return Expanded(
        child: Center(
          child: viewModel.searchTerm.isEmpty
              ? Text(Strings.searchResultsAppearHere.tr())
              : Text(Strings.noResultsFound.tr()),
        ),
      );
    }

    if (showLoading) {
      return const SearchPageLoadingShimmer();
    } else {
      return Expanded(
        child: UIList<SearchScreenIntent>(
          renderers: {
            UICity: UICityRenderer(),
          },
          items: searchList,
          intentHandler: viewModel.onIntent,
        ),
      );
    }
  }
}

class SearchPageLoadingShimmer extends StatelessWidget {
  const SearchPageLoadingShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.1),
        highlightColor: Theme.of(context).primaryColor.withOpacity(0.2),
        period: const Duration(seconds: 1),
        direction: ShimmerDirection.ltr,
        child: ListView.builder(
          itemBuilder: (context, index) {
            return const Padding(
              padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Card(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                ),
              ),
            );
          },
          itemCount: 3,
        ),
      ),
    );
  }
}