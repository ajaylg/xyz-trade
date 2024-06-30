import 'package:flutter/material.dart';
import 'package:trading_app/src/models/algorithmic_model.dart';

import '../../../styles/app_colors.dart';

class AlgorithmTile extends StatefulWidget {
  final AlgorithmicModel algorithmicModel;
  const AlgorithmTile({required this.algorithmicModel, super.key});

  @override
  State<AlgorithmTile> createState() => _AlgorithmTileState();
}

class _AlgorithmTileState extends State<AlgorithmTile> {
  final String rupeeSymbol = "\u20B9";
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.algorithmicModel.symbol ?? "--",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      Text(widget.algorithmicModel.ordAction!,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: widget.algorithmicModel.ordAction == "Buy"
                                  ? AppColors.positiveColor
                                  : AppColors.negativeColor)),
                      const SizedBox(width: 18),
                      (widget.algorithmicModel.algoStatus == 'Executed')
                          ? Text(
                              "${widget.algorithmicModel.qty} / ${widget.algorithmicModel.qty} Qty",
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black45))
                          : Text("0 / ${widget.algorithmicModel.qty} Qty",
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black45)),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: widget.algorithmicModel.algoStatus == 'Executed'
                          ? AppColors.positiveColor
                          : AppColors.primaryColor),
                  borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              child: Text(widget.algorithmicModel.algoStatus!,
                  style: TextStyle(
                      fontSize: 14,
                      color: widget.algorithmicModel.algoStatus == 'Executed'
                          ? AppColors.positiveColor
                          : AppColors.primaryColor,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}
