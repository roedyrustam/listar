import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:listar/blocs/bloc.dart';
import 'package:listar/configs/config.dart';
import 'package:listar/models/model.dart';
import 'package:listar/utils/utils.dart';
import 'package:listar/widgets/widget.dart';

class ThemeSetting extends StatefulWidget {
  const ThemeSetting({Key? key}) : super(key: key);

  @override
  _ThemeSettingState createState() {
    return _ThemeSettingState();
  }
}

class _ThemeSettingState extends State<ThemeSetting> {
  ThemeModel _currentTheme = AppBloc.themeCubit.state.theme;
  bool _custom = false;
  Color? _primaryColor;
  Color? _secondaryColor;

  @override
  void initState() {
    super.initState();
    if (_currentTheme.name == 'custom') _custom = true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///On Change Theme
  void onChange() {
    ThemeModel theme = _currentTheme;
    if (_custom) {
      theme = ThemeModel(
        name: 'custom',
        primary: _primaryColor ?? Theme.of(context).primaryColor,
        secondary: _secondaryColor ?? Theme.of(context).colorScheme.secondary,
      );
    }
    AppBloc.themeCubit.onChangeTheme(theme: theme);
  }

  ///On Switch
  void onSwitchMode(bool value) {
    setState(() {
      _custom = value;
    });
  }

  ///On Select Color
  Future<Color?> onSelectColor(Color current) async {
    return await showDialog<Color?>(
      context: context,
      builder: (BuildContext context) {
        Color? selected;
        return AlertDialog(
          title: Text(Translate.of(context).translate('choose_color')),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: current,
              onColorChanged: (color) {
                selected = color;
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            AppButton(
              Translate.of(context).translate('close'),
              onPressed: () {
                Navigator.pop(context);
              },
              type: ButtonType.text,
            ),
            AppButton(
              Translate.of(context).translate('apply'),
              onPressed: () {
                Navigator.pop(context, selected);
              },
            ),
          ],
        );
      },
    );
  }

  ///On Choose Primary
  void onChoosePrimary() async {
    final result = await onSelectColor(
      _primaryColor ?? Theme.of(context).primaryColor,
    );
    if (result != null) {
      setState(() {
        _primaryColor = result;
      });
    }
  }

  ///On Choose Secondary
  void onChooseSecondary() async {
    final result = await onSelectColor(
      _secondaryColor ?? Theme.of(context).colorScheme.secondary,
    );
    if (result != null) {
      setState(() {
        _secondaryColor = result;
      });
    }
  }

  ///Build content
  Widget buildContent() {
    Widget content = ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        Widget trailing = Container();
        final item = AppTheme.themeSupport[index];
        if (item.name == _currentTheme.name) {
          trailing = Icon(
            Icons.check,
            color: Theme.of(context).primaryColor,
          );
        }

        return AppListTitle(
          title: Translate.of(context).translate(item.name),
          leading: Container(
            width: 24,
            height: 24,
            color: item.primary,
          ),
          trailing: trailing,
          onPressed: () {
            setState(() {
              _currentTheme = item;
            });
          },
          border: index != AppTheme.themeSupport.length - 1,
        );
      },
      itemCount: AppTheme.themeSupport.length,
    );
    if (_custom) {
      content = Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Translate.of(context).translate('primary_color'),
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  AppPickerItem(
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _primaryColor ?? Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    title: Translate.of(context).translate('choose_color'),
                    onPressed: onChoosePrimary,
                  )
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Translate.of(context).translate('secondary_color'),
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  AppPickerItem(
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _secondaryColor ??
                            Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    title: Translate.of(context).translate('choose_color'),
                    onPressed: onChooseSecondary,
                  )
                ],
              ),
            )
          ],
        ),
      );
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('theme'),
        ),
        elevation: 0,
        actions: [
          AppButton(
            Translate.of(context).translate('apply'),
            onPressed: onChange,
            type: ButtonType.text,
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            AppListTitle(
              leading: Icon(
                Icons.color_lens_outlined,
                color: Theme.of(context).primaryColor,
              ),
              title: Translate.of(context).translate('custom_color'),
              trailing: CupertinoSwitch(
                activeColor: Theme.of(context).primaryColor,
                value: _custom,
                onChanged: onSwitchMode,
              ),
              border: false,
            ),
            Expanded(child: buildContent())
          ],
        ),
      ),
    );
  }
}
