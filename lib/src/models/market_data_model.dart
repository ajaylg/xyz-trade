class MarketData {
  MarketData({this.symbol, this.price, this.open, this.high, this.low});
  String? symbol;
  String? price;
  String? open;
  String? high;
  String? low;

  MarketData.fromJson(Map<String, dynamic> json) {
    symbol = json['symbol'];
    price = json['price'];
    open = json['open'];
    high = json['high'];
    low = json['low'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['symbol'] = symbol;
    data['price'] = price;
    data['open'] = open;
    data['high'] = high;
    data['low'] = low;
    return data;
  }
}
