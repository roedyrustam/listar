import 'package:flutter/material.dart';
import 'package:listar/models/model.dart';
import 'package:listar/utils/datetime.dart';
import 'package:listar/widgets/app_placeholder.dart';

class AppBookingItem extends StatelessWidget {
  final BookingItemModel? item;
  final VoidCallback? onPressed;

  const AppBookingItem({
    Key? key,
    this.item,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (item != null) {
      return InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1,
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item?.title ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item?.id}',
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item?.date?.dateView ?? '',
                    style: Theme.of(context).textTheme.caption,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item?.status ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .button!
                        .copyWith(color: item?.statusColor),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }

    return AppPlaceholder(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 10,
                    width: 100,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 150,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 10,
                  width: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: 100,
                  color: Colors.white,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
