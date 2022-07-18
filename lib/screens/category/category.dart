import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listar/blocs/bloc.dart';
import 'package:listar/configs/config.dart';
import 'package:listar/models/model.dart';
import 'package:listar/utils/utils.dart';
import 'package:listar/widgets/widget.dart';

class Category extends StatefulWidget {
  const Category({Key? key}) : super(key: key);

  @override
  _CategoryState createState() {
    return _CategoryState();
  }
}

class _CategoryState extends State<Category> {
  final _categoryCubit = CategoryCubit();
  final _textController = TextEditingController();

  CategoryView _type = CategoryView.full;

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  @override
  void dispose() {
    _categoryCubit.close();
    _textController.dispose();
    super.dispose();
  }

  ///On refresh list
  Future<void> _onRefresh() async {
    await _categoryCubit.onLoad(_textController.text);
  }

  ///On clear search
  void _onClearTapped() async {
    _textController.text = '';
    _onSearch('');
  }

  ///On change mode view
  void _onChangeModeView() {
    switch (_type) {
      case CategoryView.full:
        setState(() {
          _type = CategoryView.icon;
        });
        break;
      case CategoryView.icon:
        setState(() {
          _type = CategoryView.full;
        });
        break;
      default:
        break;
    }
  }

  ///On navigate list product
  void _onProductList(CategoryModel item) {
    Navigator.pushNamed(
      context,
      Routes.listProduct,
      arguments: item,
    );
  }

  ///On Search Category
  void _onSearch(String text) {
    _onRefresh();
  }

  ///Export icon
  IconData _exportIcon(CategoryView _type) {
    switch (_type) {
      case CategoryView.icon:
        return Icons.view_headline;
      default:
        return Icons.view_agenda;
    }
  }

  ///Build content list
  Widget _buildContent(List<CategoryModel>? category) {
    ///Success
    if (category != null) {
      ///Empty
      if (category.isEmpty) {
        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.sentiment_satisfied),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  Translate.of(context).translate(
                    'category_not_found',
                  ),
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.separated(
          itemCount: category.length,
          separatorBuilder: (context, index) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(),
            );
          },
          itemBuilder: (context, index) {
            final item = category[index];
            return AppCategory(
              type: _type,
              item: item,
              onPressed: () {
                _onProductList(item);
              },
            );
          },
        ),
      );
    }

    ///Loading
    return ListView.separated(
      itemCount: List.generate(8, (index) => index).length,
      separatorBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(),
        );
      },
      itemBuilder: (context, index) {
        return AppCategory(type: _type);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _categoryCubit,
      child: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          List<CategoryModel>? category;
          if (state is CategorySuccess) {
            category = state.list;
          }
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(Translate.of(context).translate('category')),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    _exportIcon(_type),
                  ),
                  onPressed: _onChangeModeView,
                )
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 16),
                    AppTextInput(
                      hintText: Translate.of(context).translate('search'),
                      controller: _textController,
                      trailing: GestureDetector(
                        dragStartBehavior: DragStartBehavior.down,
                        onTap: _onClearTapped,
                        child: const Icon(Icons.clear),
                      ),
                      onSubmitted: _onSearch,
                      onChanged: _onSearch,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildContent(category),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
