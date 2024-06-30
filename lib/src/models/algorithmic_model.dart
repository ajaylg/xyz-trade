class AlgorithmicModel {
  AlgorithmicModel(
      {this.symbol, this.ordAction, this.qty, this.checkPerc, this.algoStatus});
  String? symbol;
  String? ordAction;
  String? qty;
  String? checkPerc;
  String? algoStatus;

  AlgorithmicModel.fromJson(Map<String, dynamic> json) {
    symbol = json['symbol'];
    ordAction = json['ordAction'];
    qty = json['qty'];
    checkPerc = json['checkPerc'];
    algoStatus = json['algoStatus'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['symbol'] = symbol;
    data['ordAction'] = ordAction;
    data['qty'] = qty;
    data['checkPerc'] = checkPerc;
    data['algoStatus'] = algoStatus;
    return data;
  }
}
