import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_app/src/models/order_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../models/algorithmic_model.dart';
import '../../models/market_data_model.dart';
import '../../models/user_model.dart';
import '../../repository/cache_repository.dart';

part 'watchlist_event.dart';
part 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  late User userData;
  late Isolate _isolate;
  late ReceivePort _receivePort;
  WatchlistData watchlistData = WatchlistData();
  PlaceOrderSuccess placeOrderSuccess = PlaceOrderSuccess();
  AlgorithmSuccess algorithmSuccess = AlgorithmSuccess();
  final String rupeeSymbol = "\u20B9";

  WatchlistBloc() : super(WatchlistChange()) {
    on<GetUserData>(_fetchUserData);
    on<WebSocketConnect>(_connectSocket);
    on<WebSocketDisconnect>(_disConnectSocket);
    on<WebSocketDataReceived>(_receivedData);
    on<PlaceOrder>(_placeOrder);
    on<FetchOrderHistory>(_fetchOrderHistory);
    on<CreateAlgorithm>(_createAlgorithm);
    on<CheckAlgorithm>(_checkAlgorithm);
    on<FetchAlgorithms>(_fetchAlgorithms);
  }

  Future<FutureOr<void>> _fetchOrderHistory(
      FetchOrderHistory event, emit) async {
    List<String> cacheData = await CacheRepository.getListData("ordersHistory");
    List<Order> orderData = [];
    if (cacheData.isNotEmpty) {
      orderData = cacheData
          .map((jsonOrder) => Order.fromJson(jsonDecode(jsonOrder)))
          .toList();
    }
    emit(OrderHistoryLoading());
    emit(placeOrderSuccess..orders = List<Order>.from(orderData));
  }

  Future<FutureOr<void>> _fetchAlgorithms(FetchAlgorithms event, emit) async {
    List<String> cacheData = await CacheRepository.getListData("algorithms");
    List<AlgorithmicModel> algoData = [];
    if (cacheData.isNotEmpty) {
      algoData = cacheData
          .map((jsonOrder) => AlgorithmicModel.fromJson(jsonDecode(jsonOrder)))
          .toList();
    }
    emit(AlgorithmLoading());
    emit(algorithmSuccess..algoData = List<AlgorithmicModel>.from(algoData));
  }

  Future<FutureOr<void>> _createAlgorithm(CreateAlgorithm event, emit) async {
    await Future.delayed(const Duration(seconds: 3));
    List<String> cacheData = await CacheRepository.getListData("algorithms");
    cacheData.add(jsonEncode(event.algoData.toJson()));
    await CacheRepository.saveListData("algorithms", cacheData);
    if (algorithmSuccess.algoData != null &&
        algorithmSuccess.algoData!.isNotEmpty) {
      algorithmSuccess.algoData!.add(event.algoData);
      emit(AlgorithmLoading());
      emit(algorithmSuccess
        ..algoData = List<AlgorithmicModel>.from(algorithmSuccess.algoData!));
    } else {
      algorithmSuccess.algoData = [event.algoData];
      emit(AlgorithmLoading());
      emit(algorithmSuccess
        ..algoData = List<AlgorithmicModel>.from(algorithmSuccess.algoData!));
    }
  }

  Future<FutureOr<void>> _checkAlgorithm(CheckAlgorithm event, emit) async {
    List<String> cacheData = await CacheRepository.getListData("algorithms");
    if (cacheData.isNotEmpty) {
      List<AlgorithmicModel> algoData = cacheData
          .map((jsonOrder) => AlgorithmicModel.fromJson(jsonDecode(jsonOrder)))
          .toList();

      if (watchlistData.marketData != null &&
          watchlistData.marketData!.isNotEmpty) {
        for (var data in algoData) {
          if (data.algoStatus == 'Active') {
            final resultData = watchlistData.marketData!
                .firstWhere((element) => element.symbol == data.symbol);
            final double resultPrice = double.parse(resultData.price!);
            final double percentage = double.parse(data.checkPerc!);
            if (data.ordAction == "Buy") {
              if (shouldBuy(
                  resultPrice, double.parse(resultData.high!), percentage)) {
                _placeOrderData(data, resultData, resultPrice);
                data.algoStatus = "Executed";
                algorithmSuccess = AlgorithmSuccess(
                    algoData: List<AlgorithmicModel>.from(algoData));
                emit(algorithmSuccess);
                List<String> encodedData =
                    algoData.map((e) => jsonEncode(e.toJson())).toList();
                await CacheRepository.saveListData("algorithms", encodedData);
              }
            } else if (data.ordAction == "Sell") {
              if (shouldSell(
                  resultPrice, double.parse(resultData.low!), percentage)) {
                _placeOrderData(data, resultData, resultPrice);
                data.algoStatus = "Executed";
                algorithmSuccess = AlgorithmSuccess(
                    algoData: List<AlgorithmicModel>.from(algoData));
                emit(algorithmSuccess);
                List<String> encodedData =
                    algoData.map((e) => jsonEncode(e.toJson())).toList();
                await CacheRepository.saveListData("algorithms", encodedData);
              }
            }
          }
        }
      }
    }
  }

  void _placeOrderData(
      AlgorithmicModel data, MarketData resultData, double resultPrice) {
    String amount = (resultPrice * int.parse(data.qty!)).toStringAsFixed(2);
    Order orderData = Order.fromJson({
      'ordAction': data.ordAction,
      'ordId': generateOrderId(),
      'ordDate': getCurrentDateTimeString(),
      'symbol': resultData.symbol,
      'qty': data.qty!,
      'price': amount,
      'ordStatus': 'Success'
    });

    add(PlaceOrder(orderData));
  }

  String getCurrentDateTimeString() {
    final now = DateTime.now();
    return "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} "
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
  }

  String generateOrderId() {
    return (Random().nextInt(900000) + 100000).toString();
  }

  bool shouldBuy(double price, double high, double percentage) =>
      price <= high * (1 - percentage / 100);

  bool shouldSell(double price, double low, double percentage) =>
      price >= low * (1 + percentage / 100);

  Future<FutureOr<void>> _placeOrder(PlaceOrder event, emit) async {
    await Future.delayed(const Duration(seconds: 3));
    List<String> cacheData = await CacheRepository.getListData("ordersHistory");
    cacheData.add(jsonEncode(event.order.toJson()));
    await CacheRepository.saveListData("ordersHistory", cacheData);
    if (placeOrderSuccess.orders != null &&
        placeOrderSuccess.orders!.isNotEmpty) {
      placeOrderSuccess.orders!.add(event.order);
      emit(OrderHistoryLoading());
      emit(placeOrderSuccess..orders = List.from(placeOrderSuccess.orders!));
    } else {
      placeOrderSuccess.orders = [event.order];
      emit(OrderHistoryLoading());
      emit(placeOrderSuccess..orders = List.from(placeOrderSuccess.orders!));
    }
  }

  Future<FutureOr<void>> _fetchUserData(GetUserData event, emit) async {
    emit(AuthUserLoading());
    userData = User.fromJson(await CacheRepository.getData('userData'));
    emit(AuthUserData(userData));
  }

  Future<FutureOr<void>> _connectSocket(WebSocketConnect event, emit) async {
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_webSocketIsolate, _receivePort.sendPort);
    _receivePort.listen((message) {
      if (message == null) {
        return;
      } else {
        List<dynamic> decodedJson = jsonDecode(message);
        List<Map<String, String>> processedData =
            decodedJson.map((item) => Map<String, String>.from(item)).toList();
        List<MarketData> marketData =
            processedData.map((e) => MarketData.fromJson(e)).toList();
        marketData = _updateStreamingValues(marketData);
        add(WebSocketDataReceived(marketData));
      }
    });
  }

  Future<FutureOr<void>> _disConnectSocket(
      WebSocketDisconnect event, emit) async {
    _isolate.kill(priority: Isolate.immediate);
    _receivePort.close();
  }

  Future<FutureOr<void>> _receivedData(
      WebSocketDataReceived event, emit) async {
    watchlistData =
        WatchlistData(marketData: List<MarketData>.from(event.marketData));
    emit(watchlistData);
    add(CheckAlgorithm());
  }

//update open/high/price
  List<MarketData> _updateStreamingValues(List<MarketData> marketData) {
    if (watchlistData.marketData == null || watchlistData.marketData!.isEmpty) {
      for (var element in marketData) {
        element.open = element.high = element.low = element.price;
      }
    } else {
      for (var element in watchlistData.marketData!) {
        final resultData =
            marketData.firstWhere((e) => e.symbol == element.symbol);
        final double resultPrice = double.parse(resultData.price!);
        element.price = resultData.price;
        element.high = (resultPrice > double.parse(element.high!))
            ? resultData.price!
            : element.high;
        element.low = (resultPrice < double.parse(element.low!))
            ? resultData.price!
            : element.low;
      }
      marketData = List<MarketData>.from(watchlistData.marketData!);
    }
    return marketData;
  }

  @override
  Future<void> close() {
    _isolate.kill(priority: Isolate.immediate);
    _receivePort.close();
    return super.close();
  }

  static void _webSocketIsolate(SendPort sendPort) async {
    try {
      String? socketUrl;
      if (Platform.isAndroid) {
        socketUrl = "ws://10.0.2.2:8080";
      } else {
        socketUrl = "ws://localhost:8080";
      }
      final channel = WebSocketChannel.connect(Uri.parse(socketUrl));
      await channel.ready;
      channel.stream.listen(
        (message) {
          sendPort.send(message);
        },
        onDone: () {
          sendPort.send(null);
        },
        onError: (error) {
          sendPort.send(null);
        },
      );
    } catch (e) {
      sendPort.send(null);
      print('WebSocket connection error: $e');
    }
  }
}
