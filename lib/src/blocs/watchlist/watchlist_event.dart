part of 'watchlist_bloc.dart';

abstract class WatchlistEvent {}

class GetUserData extends WatchlistEvent {}

class WebSocketConnect extends WatchlistEvent {}

class WebSocketDisconnect extends WatchlistEvent {}

class WebSocketDataReceived extends WatchlistEvent {
  List<MarketData> marketData;
  WebSocketDataReceived(this.marketData);
}

class PlaceOrder extends WatchlistEvent {
  Order order;
  PlaceOrder(this.order);
}

class CreateAlgorithm extends WatchlistEvent {
  AlgorithmicModel algoData;
  CreateAlgorithm(this.algoData);
}

class CheckAlgorithm extends WatchlistEvent {

}

class FetchOrderHistory extends WatchlistEvent {

}

class FetchAlgorithms extends WatchlistEvent {

}