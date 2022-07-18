import 'package:flutter/material.dart';
import 'package:listar/configs/config.dart';
import 'package:listar/models/model.dart';
import 'package:listar/repository/repository.dart';
import 'package:listar/utils/utils.dart';
import 'package:listar/widgets/widget.dart';

enum TimeType { start, end }

class Filter extends StatefulWidget {
  final FilterModel filter;
  const Filter({Key? key, required this.filter}) : super(key: key);

  @override
  _FilterState createState() {
    return _FilterState();
  }
}

class _FilterState extends State<Filter> {
  late FilterModel _filter;

  bool _loadingArea = false;
  RangeValues? _rangeValues;
  List<CategoryModel> _listArea = [];

  @override
  void initState() {
    super.initState();
    _rangeValues = RangeValues(
      widget.filter.minPrice ?? ListSetting.minPrice,
      widget.filter.maxPrice ?? ListSetting.maxPrice,
    );
    _filter = widget.filter;
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///Export String hour
  String _labelTime(TimeOfDay time) {
    final hourLabel = time.hour < 10 ? '0${time.hour}' : '${time.hour}';
    final minLabel = time.minute < 10 ? '0${time.minute}' : '${time.minute}';
    return '$hourLabel:$minLabel';
  }

  ///Show Picker Time
  Future<void> _showTimePicker(BuildContext context, TimeType type) async {
    final picked = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );
    if (type == TimeType.start && picked != null) {
      setState(() {
        _filter.startHour = picked;
      });
    }
    if (type == TimeType.end && picked != null) {
      setState(() {
        _filter.endHour = picked;
      });
    }
  }

  ///On Filter Are
  void _onChangeLocation() async {
    final selected = await Navigator.pushNamed(
      context,
      Routes.picker,
      arguments: PickerModel(
        title: Translate.of(context).translate('select_location'),
        selected: [_filter.location],
        data: ListSetting.locations,
      ),
    );
    if (selected != null && selected is CategoryModel) {
      setState(() {
        _filter.location = selected;
        _filter.area = null;
        _loadingArea = true;
      });
      final result = await CategoryRepository.loadLocation(selected.id);
      if (result != null) {
        setState(() {
          _listArea = result;
          _loadingArea = false;
        });
      }
    }
  }

  ///On Navigate Filter Area
  void _onChangeArea() async {
    final selected = await Navigator.pushNamed(
      context,
      Routes.picker,
      arguments: PickerModel(
        title: Translate.of(context).translate('select_location'),
        selected: [_filter.area],
        data: _listArea,
      ),
    );
    if (selected != null && selected is CategoryModel) {
      setState(() {
        _filter.area = selected;
      });
    }
  }

  ///Apply filter
  void _onApply() {
    Navigator.pop(context, _filter);
  }

  ///Build content
  Widget _buildContent() {
    String unit = ListSetting.unit;
    Widget location = Text(
      Translate.of(context).translate('select_location'),
      style: Theme.of(context).textTheme.caption,
    );
    Widget area = Text(
      Translate.of(context).translate('select_location'),
      style: Theme.of(context).textTheme.caption,
    );
    Widget areaAction = RotatedBox(
      quarterTurns: UtilLanguage.isRTL() ? 2 : 0,
      child: const Icon(
        Icons.keyboard_arrow_right,
        textDirection: TextDirection.ltr,
      ),
    );

    if (_filter.location != null) {
      location = Text(
        _filter.location!.title,
        style: Theme.of(context)
            .textTheme
            .caption!
            .copyWith(color: Theme.of(context).primaryColor),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    if (_filter.area != null) {
      area = Text(
        _filter.area!.title,
        style: Theme.of(context)
            .textTheme
            .caption!
            .copyWith(color: Theme.of(context).primaryColor),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    if (_loadingArea) {
      areaAction = const Padding(
        padding: EdgeInsets.only(right: 8),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              Translate.of(context).translate('category'),
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ListSetting.category.map((item) {
                final selected = _filter.category.contains(item);
                return SizedBox(
                  height: 32,
                  child: FilterChip(
                    selected: selected,
                    label: Text(item.title),
                    onSelected: (check) {
                      if (check) {
                        _filter.category.add(item);
                      } else {
                        _filter.category.remove(item);
                      }
                      setState(() {});
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              Translate.of(context).translate('facilities'),
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ListSetting.features.map((item) {
                final selected = _filter.feature.contains(item);
                return SizedBox(
                  height: 32,
                  child: FilterChip(
                    selected: selected,
                    label: Text(item.title),
                    onSelected: (check) {
                      if (check) {
                        _filter.feature.add(item);
                      } else {
                        _filter.feature.remove(item);
                      }
                      setState(() {});
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _onChangeLocation,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          Translate.of(context).translate('location'),
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        location,
                      ],
                    ),
                  ),
                  RotatedBox(
                    quarterTurns: UtilLanguage.isRTL() ? 2 : 0,
                    child: const Icon(
                      Icons.keyboard_arrow_right,
                      textDirection: TextDirection.ltr,
                    ),
                  )
                ],
              ),
            ),
            Visibility(
              visible: _filter.location != null,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _onChangeArea,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                Translate.of(context).translate('area'),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              area,
                            ],
                          ),
                        ),
                        areaAction,
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  Translate.of(context).translate('price_range'),
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '${ListSetting.minPrice}',
                      style: Theme.of(context).textTheme.caption,
                    ),
                    Text(
                      '${ListSetting.maxPrice}',
                      style: Theme.of(context).textTheme.caption,
                    )
                  ],
                )
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 16,
              child: RangeSlider(
                min: ListSetting.minPrice,
                max: ListSetting.maxPrice,
                values: _rangeValues!,
                onChanged: (range) {
                  setState(() {
                    _rangeValues = range;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  Translate.of(context).translate('avg_price'),
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                Text(
                  '${_rangeValues!.start.round()} $unit- ${_rangeValues!.end.round()} $unit',
                  style: Theme.of(context).textTheme.subtitle2,
                )
              ],
            ),
            const SizedBox(height: 16),
            Text(
              Translate.of(context).translate('business_color'),
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: ListSetting.color.map((item) {
                Widget checked = Container();
                if (_filter.color == item) {
                  checked = const Icon(
                    Icons.check,
                    color: Colors.white,
                  );
                }
                return InkWell(
                  onTap: () {
                    setState(() {
                      _filter.color = item;
                    });
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: UtilColor.getColorFromHex(item),
                    ),
                    child: checked,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              Translate.of(context).translate('open_time'),
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _showTimePicker(context, TimeType.start);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              Translate.of(context).translate(
                                'start_time',
                              ),
                              style: Theme.of(context).textTheme.caption,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _labelTime(_filter.startHour!),
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    VerticalDivider(
                      color: Theme.of(context).disabledColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _showTimePicker(context, TimeType.end);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              Translate.of(context).translate(
                                'end_time',
                              ),
                              style: Theme.of(context).textTheme.caption,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _labelTime(_filter.endHour!),
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('filter'),
        ),
        actions: [
          AppButton(
            Translate.of(context).translate('apply'),
            onPressed: _onApply,
            type: ButtonType.text,
          )
        ],
      ),
      body: SafeArea(
        child: _buildContent(),
      ),
    );
  }
}
