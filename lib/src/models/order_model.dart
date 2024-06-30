import 'market_data_model.dart';

class Order extends MarketData {
  Order({this.ordAction, this.ordId, this.ordDate, this.qty, this.ordStatus});
  String? ordAction;
  String? ordId;
  String? ordDate;
  String? ordStatus;
  String? qty;

  Order.fromJson(Map<String, dynamic> json) {
    ordAction = json['ordAction'];
    ordId = json['ordId'];
    ordDate = json['ordDate'];
    ordStatus = json['ordStatus'];
    qty = json['qty'];
    symbol = json['symbol'];
    price = json['price'];
  }

  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ordAction'] = ordAction;
    data['ordId'] = ordId;
    data['ordDate'] = ordDate;
    data['ordStatus'] = ordStatus;
    data['qty'] = qty;
    data['symbol'] = symbol;
    data['price'] = price;
    return data;
  }
}
