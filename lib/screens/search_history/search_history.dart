import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listar/blocs/bloc.dart';
import 'package:listar/configs/config.dart';
import 'package:listar/models/model.dart';
import 'package:listar/utils/utils.dart';

import 'search_result_list.dart';
import 'search_suggest_list.dart';

class SearchHistory extends StatefulWidget {
  const SearchHistory({Key? key}) : super(key: key);

  @override
  _SearchHistoryState createState() {
    return _SearchHistoryState();
  }
}

class _SearchHistoryState extends State<SearchHistory> {
  late SearchHistoryDelegate _delegate;
  final _searchCubit = SearchCubit();

  List<ProductModel> _history = [];

  @override
  void initState() {
    super.initState();
    _delegate = SearchHistoryDelegate(_searchCubit);
    _loadHistory();
  }

  @override
  void dispose() {
    _searchCubit.close();
    super.dispose();
  }

  ///Load history
  void _loadHistory() async {
    List<String>? historyString = UtilPreferences.getStringList(
      Preferences.search,
    );
    if (historyString != null) {
      _history = historyString.map((e) {
        return ProductModel.fromJson(jsonDecode(e));
      }).toList();
    }
    setState(() {});
  }

  ///onShow search
  void _onSearch() async {
    await showSearch(
      context: context,
      delegate: _delegate,
    );
    _loadHistory();
  }

  void _onClear({ProductModel? item}) async {
    if (item == null) {
      await UtilPreferences.setStringList(Preferences.search, []);
    } else {
      List<String>? historyString = UtilPreferences.getStringList(
        Preferences.search,
      );
      if (historyString != null) {
        historyString.remove(jsonEncode(item.toJson()));
        await UtilPreferences.setStringList(
          Preferences.search,
          historyString,
        );
      }
    }
    _loadHistory();
  }

  ///On navigate product detail
  void _onProductDetail(ProductModel item) async {
    Navigator.pushNamed(context, Routes.productDetail, arguments: item.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: AnimatedIcon(
            icon: AnimatedIcons.close_menu,
            progress: _delegate.transitionAnimation,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(Translate.of(context).translate('search_title')),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _onSearch,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      Translate.of(context).translate('search_history'),
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                      onTap: () {
                        _onClear();
                      },
                      child: Text(
                        Translate.of(context).translate('clear'),
                        style: Theme.of(context).textTheme.subtitle2!.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    ),
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 8,
                  children: _history.map((item) {
                    return InputChip(
                      onPressed: () {
                        _onProductDetail(item);
                      },
                      label: Text(item.title),
                      onDeleted: () {
                        _onClear(item: item);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SearchHistoryDelegate extends SearchDelegate<String> {
  final SearchCubit searchCubit;
  SearchHistoryDelegate(this.searchCubit);

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, query);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    searchCubit.onSearch(query);
    return BlocProvider(
      create: (context) => searchCubit,
      child: const SuggestionList(),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return BlocProvider(
      create: (context) => searchCubit,
      child: const ResultList(),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    if (query.isNotEmpty) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        )
      ];
    }
    return [];
  }
}
