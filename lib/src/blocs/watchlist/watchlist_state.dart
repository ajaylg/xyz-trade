part of 'watchlist_bloc.dart';

abstract class WatchlistState {}

class AuthUserLoading extends WatchlistState {}

class AuthUserData extends WatchlistState {
  final User userData;
  AuthUserData(this.userData);
}

class WatchlistLoading extends WatchlistState {}

class WatchlistChange extends WatchlistState {}

class SocketExceptionFailure extends WatchlistState {}

class WatchlistData extends WatchlistState {
  List<MarketData>? marketData;
  WatchlistData({this.marketData});
}

class PlaceOrderSuccess extends WatchlistState {
  List<Order>? orders;
  PlaceOrderSuccess({this.orders});
}
class AlgorithmLoading extends WatchlistState {}
class AlgorithmSuccess extends WatchlistState {
  List<AlgorithmicModel>? algoData;
  AlgorithmSuccess({this.algoData});
}
class OrderHistoryLoading extends WatchlistState {}
