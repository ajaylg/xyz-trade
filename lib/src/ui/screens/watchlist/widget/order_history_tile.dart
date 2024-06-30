import 'package:flutter/material.dart';

import '../../../../models/order_model.dart';
import '../../../styles/app_colors.dart';

class OrderHistoryTile extends StatefulWidget {
  final Order order;
  const OrderHistoryTile({required this.order, super.key});

  @override
  State<OrderHistoryTile> createState() => _OrderHistoryTileState();
}

class _OrderHistoryTileState extends State<OrderHistoryTile> {
  final String rupeeSymbol = "\u20B9";
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.order.symbol ?? "--",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Text("$rupeeSymbol ${widget.order.price ?? "--"}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ))
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(30)),
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    child: Text(widget.order.ordId ?? "--",
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54)),
                  ),
                  Row(
                    children: [
                      Text(widget.order.ordAction!,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: widget.order.ordAction == "Buy"
                                  ? AppColors.positiveColor
                                  : AppColors.negativeColor)),
                      const SizedBox(width: 28),
                      Text(
                          "${widget.order.ordStatus == 'Success' ? widget.order.qty : 0} / ${widget.order.qty} Qty",
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black45)),
                    ],
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.order.ordDate ?? "--",
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.black45)),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: widget.order.ordStatus == 'Success'
                              ? AppColors.positiveColor
                              : AppColors.negativeColor),
                      borderRadius: BorderRadius.circular(30)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  child: Text(widget.order.ordStatus!,
                      style: TextStyle(
                          fontSize: 14,
                          color: widget.order.ordStatus == 'Success'
                              ? AppColors.positiveColor
                              : AppColors.negativeColor,
                          fontWeight: FontWeight.w500)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
