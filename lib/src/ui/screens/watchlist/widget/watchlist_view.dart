import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/watchlist/watchlist_bloc.dart';
import '../../../../models/algorithmic_model.dart';
import '../../../../models/market_data_model.dart';
import '../../../../models/order_model.dart';
import '../../../styles/app_colors.dart';

class WatchlistBuilder extends StatefulWidget {
  final List<MarketData> marketData;
  const WatchlistBuilder(this.marketData, {Key? key}) : super(key: key);

  @override
  State<WatchlistBuilder> createState() => _WatchlistBuilderState();
}

class _WatchlistBuilderState extends State<WatchlistBuilder> {
  final String rupeeSymbol = "\u20B9";
  late WatchlistBloc watchlistBloc;
  final ValueNotifier<bool> _shownBtn = ValueNotifier<bool>(true);
  late TextEditingController qtyController = TextEditingController(text: "1");
  late TextEditingController pricePercController =
      TextEditingController(text: "5");
  final popupMenus = ["Buy", "Sell", "Create Algo Strategy"];

  @override
  void initState() {
    watchlistBloc = BlocProvider.of<WatchlistBloc>(context);
    super.initState();
  }

  void _showToast(BuildContext context, String msg, {bool isFailure = false}) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        padding: const EdgeInsets.all(15),
        content: Text(
          msg,
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor:
            isFailure ? AppColors.negativeColor : AppColors.positiveColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) => _row(
            key: ValueKey("watchlistdata$index"),
            marketData: widget.marketData[index]),
        separatorBuilder: (context, index) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Divider(
                thickness: 1,
                height: 1,
              ),
            ),
        itemCount: widget.marketData.length);
  }

  Dismissible _row({Key? key, MarketData? marketData}) {
    return Dismissible(
      key: ValueKey(key),
      direction: DismissDirection.horizontal,
      background: buildBackGroundTextContainer(
        context,
        "Buy",
        AppColors.positiveColor,
        Alignment.centerLeft,
      ),
      secondaryBackground: buildBackGroundTextContainer(
        context,
        "Sell",
        AppColors.negativeColor,
        Alignment.centerRight,
      ),
      child: GestureDetector(
        child: Container(
          height: 70,
          padding: const EdgeInsets.only(left: 20, right: 6),
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                marketData!.symbol ?? "--",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              Row(
                children: [
                  Text(
                    "$rupeeSymbol ${marketData.price ?? '--'}",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.positiveColor),
                  ),
                  PopupMenuButton<String>(
                    position: PopupMenuPosition.under,
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.black45,
                    ),
                    onSelected: (String item) {
                      if (item == "Buy") {
                        _showBottomSheet(marketData, ordAction: "Buy");
                      } else if (item == "Sell") {
                        _showBottomSheet(marketData, ordAction: "Sell");
                      } else if (item == "Create Algo Strategy") {
                        _showBottomSheet(marketData, isAlgo: true);
                      }
                    },
                    itemBuilder: (BuildContext context) => List.generate(
                        3,
                        (index) => PopupMenuItem<String>(
                              value: popupMenus[index],
                              child: Text(popupMenus[index]),
                            )),
                  )
                ],
              )
            ],
          ),
        ),
        onTap: () {
          _showBottomSheet(marketData);
        },
      ),
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.startToEnd) {
          _showBottomSheet(marketData, ordAction: "Buy");
        } else if (direction == DismissDirection.endToStart) {
          _showBottomSheet(marketData, ordAction: "Sell");
        }
        return false;
      },
    );
  }

  Future<void> _showBottomSheet(MarketData marketData,
      {String ordAction = 'Buy', bool isAlgo = false}) async {
    qtyController = TextEditingController(text: "1");
    if (isAlgo == true) {
      pricePercController = TextEditingController(text: "5");
    }
    _shownBtn.value = true;
    String action = ordAction;
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
              left: 25,
              right: 25,
              top: 25,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: BlocProvider.value(
            value: watchlistBloc,
            child: StatefulBuilder(builder: (_, StateSetter updateState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        marketData.symbol ?? "--",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      Row(
                        children: [
                          ToggleButtons(
                            onPressed: (int index) {
                              updateState(() {
                                action = index == 0 ? "Buy" : 'Sell';
                              });
                            },
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                            borderColor: Theme.of(context).dividerColor,
                            selectedBorderColor: action == 'Buy'
                                ? AppColors.positiveColor
                                : AppColors.negativeColor,
                            selectedColor: Colors.white,
                            fillColor: action == 'Buy'
                                ? AppColors.positiveColor
                                : AppColors.negativeColor,
                            constraints: const BoxConstraints(
                              minHeight: 30.0,
                              minWidth: 60.0,
                            ),
                            isSelected: [
                              action == 'Buy' ? true : false,
                              action == 'Sell' ? true : false,
                            ],
                            children: const [Text('Buy'), Text('Sell')],
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.close)),
                        ],
                      )
                    ],
                  ),
                  BlocBuilder<WatchlistBloc, WatchlistState>(
                    bloc: watchlistBloc,
                    buildWhen: (previous, current) =>
                        current is WatchlistLoading ||
                        current is WatchlistChange ||
                        current is WatchlistData,
                    builder: (context, state) {
                      if (state is WatchlistData) {
                        final livePrice = state.marketData!
                            .firstWhere((element) =>
                                element.symbol == marketData.symbol)
                            .price;
                        return Text("$rupeeSymbol $livePrice",
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54));
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                  Align(alignment: Alignment.center, child: qty(marketData)),
                  if (isAlgo == true)
                    Align(
                        alignment: Alignment.center,
                        child: _pricePerc(marketData, action)),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: SizedBox(
                          height: 50,
                          width: 300,
                          child: ValueListenableBuilder<bool>(
                              valueListenable: _shownBtn,
                              builder: (context, showBtn, _) {
                                return ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: isAlgo == false
                                            ? action == 'Buy'
                                                ? AppColors.positiveColor
                                                : AppColors.negativeColor
                                            : AppColors.primaryColor,
                                        shape: const StadiumBorder()),
                                    onPressed: (showBtn == true &&
                                            qtyController.text.isNotEmpty &&
                                            int.parse(qtyController.text) > 0)
                                        ? () {
                                            if (isAlgo == false) {
                                              _placeOrder(marketData, action);
                                            } else {
                                              _createAlgorithm(
                                                  marketData, action);
                                            }
                                          }
                                        : null,
                                    child: Text(
                                      isAlgo == false ? action : "Create",
                                      style: const TextStyle(fontSize: 20),
                                    ));
                              })),
                    ),
                  )
                ],
              );
            }),
          ),
        );
      },
    );
  }

  qtyInc() {
    String value;
    if (qtyController.text.isEmpty) {
      value = "1";
    } else {
      value = (int.parse(qtyController.text) + 1).toString();
    }
    qtyController
      ..text = value
      ..selection = TextSelection.collapsed(offset: value.length);
    _shownBtn.value = true;
  }

  qtyDec() {
    if ((qtyController.text.isNotEmpty && int.parse(qtyController.text) > 0)) {
      String value = (int.parse(qtyController.text) - 1).toString();
      value != "0"
          ? (qtyController
            ..text = value
            ..selection = TextSelection.collapsed(offset: value.length))
          : qtyController.text = "";
      _shownBtn.value = qtyController.text.isEmpty ? false : true;
    }
  }

  _placeOrder(MarketData marketData, String ordAction) {
    if (qtyController.text.isNotEmpty && int.parse(qtyController.text) > 0) {
      Navigator.pop(context);
      String amnt = (double.parse(watchlistBloc.watchlistData.marketData!
                  .firstWhere((element) => element.symbol == marketData.symbol)
                  .price!
                  .toString()) *
              int.parse(qtyController.text.isEmpty ? "0" : qtyController.text))
          .toStringAsFixed(2);
      final now = DateTime.now();
      String convertedDateTime =
          "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
      Order orderData = Order.fromJson({
        'ordAction': ordAction,
        'ordId': (Random().nextInt(900000) + 100000).toString(),
        'ordDate': convertedDateTime,
        'symbol': marketData.symbol,
        'qty': qtyController.text,
        'price': amnt,
        'ordStatus': 'Success' //failure //pending
      });

      watchlistBloc.add(PlaceOrder(orderData));
      _showToast(context, "Order Placed Successful!");
    }
  }

  _createAlgorithm(MarketData marketData, String ordAction) {
    if (qtyController.text.isNotEmpty &&
        int.parse(qtyController.text) > 0 &&
        pricePercController.text.isNotEmpty &&
        int.parse(pricePercController.text) > 0) {
      Navigator.pop(context);
      AlgorithmicModel algoData = AlgorithmicModel.fromJson({
        'ordAction': ordAction,
        'symbol': marketData.symbol,
        'qty': qtyController.text,
        'checkPerc': pricePercController.text,
        'algoStatus': 'Active' //inactive //active //executed
      });
      watchlistBloc.add(CreateAlgorithm(algoData));
      _showToast(context, "Algo Strategy created successful!");
    }
  }

  Widget qty(MarketData marketData, {bool isAlgo = true}) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              "Quantity",
              style: TextStyle(fontSize: 16),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(3),
            width: 200,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                    width: 1.5, color: Theme.of(context).dividerColor)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () {
                      qtyDec();
                    },
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.black45,
                      size: 26,
                    )),
                Expanded(
                  child: TextFormField(
                    controller: qtyController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    enableInteractiveSelection: true,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    cursorColor: Colors.black45,
                    decoration: const InputDecoration(
                        hintText: "0",
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none),
                    onChanged: (value) {
                      qtyController.value = TextEditingValue(
                          text: qtyController.text,
                          selection: TextSelection.collapsed(
                              offset: qtyController.text.length));
                      _shownBtn.value = (qtyController.text.isNotEmpty &&
                              int.parse(qtyController.text) > 0)
                          ? true
                          : false;
                    },
                  ),
                ),
                IconButton(
                    onPressed: () {
                      qtyInc();
                    },
                    icon: const Icon(
                      Icons.add_circle_outline_outlined,
                      color: Colors.black45,
                      size: 26,
                    )),
              ],
            ),
          ),
          if (isAlgo == false)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: BlocBuilder<WatchlistBloc, WatchlistState>(
                bloc: watchlistBloc,
                buildWhen: (previous, current) =>
                    current is WatchlistLoading ||
                    current is WatchlistChange ||
                    current is WatchlistData && (qtyController.text.isNotEmpty),
                builder: (context, state) {
                  String amnt = "0";
                  if (state is WatchlistData) {
                    amnt = (double.parse(state.marketData!
                                .firstWhere((element) =>
                                    element.symbol == marketData.symbol)
                                .price!
                                .toString()) *
                            int.parse(qtyController.text.isEmpty
                                ? "0"
                                : qtyController.text))
                        .toStringAsFixed(2);
                  }

                  return Text(
                    "Amount: $rupeeSymbol $amnt",
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _pricePerc(MarketData marketData, String action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              action == "Buy"
                  ? "Price moves down by (%)"
                  : "Price moves up by (%)",
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(3),
            width: 200,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                    width: 1.5, color: Theme.of(context).dividerColor)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: pricePercController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    enableInteractiveSelection: true,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    cursorColor: Colors.black45,
                    decoration: const InputDecoration(
                      hintText: "0",
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      prefix: SizedBox(width: 22),
                      suffix: Padding(
                        padding: EdgeInsets.only(right: 14.0),
                        child: Text("%",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    onChanged: (value) {
                      pricePercController.value = TextEditingValue(
                          text: pricePercController.text,
                          selection: TextSelection.collapsed(
                              offset: pricePercController.text.length));
                      _shownBtn.value = (pricePercController.text.isNotEmpty &&
                              int.parse(pricePercController.text) > 0)
                          ? true
                          : false;
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBackGroundTextContainer(
    BuildContext context,
    String title,
    Color color,
    Alignment alignment,
  ) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.all(16),
      color: color,
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
