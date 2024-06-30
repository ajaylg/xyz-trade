import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_app/src/blocs/watchlist/watchlist_bloc.dart';
import 'package:trading_app/src/repository/cache_repository.dart';
import 'package:trading_app/src/ui/screens/watchlist/widget/algorithm_list_tile.dart';
import 'package:trading_app/src/ui/styles/app_colors.dart';

import '../../../blocs/login/login_bloc.dart';
import '../login/login.dart';
import 'widget/order_history_tile.dart';
import 'widget/watchlist_view.dart';

class WatchListScreen extends StatefulWidget {
  const WatchListScreen({super.key});

  @override
  State<WatchListScreen> createState() => _WatchListScreenState();
}

class _WatchListScreenState extends State<WatchListScreen> {
  late WatchlistBloc watchlistBloc;
  @override
  void initState() {
    watchlistBloc = BlocProvider.of<WatchlistBloc>(context)
      ..add(WebSocketConnect())
      ..add(GetUserData())
      ..add(FetchOrderHistory())
      ..add(FetchAlgorithms());
    super.initState();
  }

  @override
  void dispose() {
    watchlistBloc.add(WebSocketDisconnect());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        title: _logo(),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.exit_to_app,
              color: Colors.black45,
            ),
            onPressed: () {
              showAlertDialog(context);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _welcomeBanner(),
              _watchlistBuilder(),
              _orderHistory(),
              _algorithms()
            ],
          ),
        ),
      ),
    );
  }

  Widget _welcomeBanner() {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      bloc: watchlistBloc,
      buildWhen: (previous, current) =>
          current is AuthUserLoading || current is AuthUserData,
      builder: (context, state) {
        if (state is AuthUserData) {
          return Padding(
            padding: const EdgeInsets.only(top: 25, bottom: 30),
            child: Container(
              height: 45,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.primaryColor.withOpacity(0.15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "🎊 Welcome ${state.userData.firstName!}!, Let's Trade...",
                  style: const TextStyle(
                      color: Color(0xff735DA5),
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _watchlistBuilder() {
    return Material(
      borderRadius: BorderRadius.circular(10),
      elevation: 4,
      shadowColor: Theme.of(context).dividerColor,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          border: Border.all(
            width: 0.5,
            color: Theme.of(context).dividerColor,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 18, right: 8, top: 20),
              child: Row(
                children: const [
                  Icon(
                    Icons.bookmark_added,
                    color: AppColors.primaryColor,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Watchlist',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            BlocBuilder<WatchlistBloc, WatchlistState>(
              bloc: watchlistBloc,
              buildWhen: (previous, current) =>
                  current is WatchlistLoading ||
                  current is WatchlistChange ||
                  current is WatchlistData ||
                  current is SocketExceptionFailure,
              builder: (context, state) {
                if (state is WatchlistData) {
                  return WatchlistBuilder(state.marketData ?? []);
                } else if (state is WatchlistLoading) {
                  return const SizedBox(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryColor),
                    ),
                  );
                } else {
                  return const SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        "No data available",
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderHistory() {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 4,
        shadowColor: Theme.of(context).dividerColor,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            border: Border.all(
              width: 0.5,
              color: Theme.of(context).dividerColor,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18, right: 8, top: 20),
                child: Row(
                  children: const [
                    Icon(
                      Icons.shopping_cart,
                      color: AppColors.primaryColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Order History',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              BlocBuilder<WatchlistBloc, WatchlistState>(
                bloc: watchlistBloc,
                buildWhen: (previous, current) =>
                    current is OrderHistoryLoading ||
                    current is PlaceOrderSuccess,
                builder: (context, state) {
                  if (state is PlaceOrderSuccess) {
                    if (state.orders!.isEmpty) {
                      return const SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            "No History found..",
                            style:
                                TextStyle(fontSize: 18, color: Colors.black54),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) => OrderHistoryTile(
                              order: state.orders![index],
                            ),
                        separatorBuilder: (context, index) => const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Divider(
                                thickness: 1,
                                height: 1,
                              ),
                            ),
                        itemCount: state.orders?.length ?? 0);
                  } else if (state is WatchlistLoading) {
                    return const SizedBox(
                      height: 400,
                      child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryColor),
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _algorithms() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 4,
        shadowColor: Theme.of(context).dividerColor,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            border: Border.all(
              width: 0.5,
              color: Theme.of(context).dividerColor,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18, right: 8, top: 20),
                child: Row(
                  children: const [
                    Icon(
                      Icons.stacked_line_chart,
                      color: AppColors.primaryColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Algo Strategy',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              BlocBuilder<WatchlistBloc, WatchlistState>(
                bloc: watchlistBloc,
                buildWhen: (previous, current) =>
                    current is AlgorithmLoading || current is AlgorithmSuccess,
                builder: (context, state) {
                  if (state is AlgorithmSuccess) {
                    if (state.algoData!.isEmpty) {
                      return const SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            "No Strategies found..",
                            style:
                                TextStyle(fontSize: 18, color: Colors.black54),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) => AlgorithmTile(
                              algorithmicModel: state.algoData![index],
                            ),
                        separatorBuilder: (context, index) => const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Divider(
                                thickness: 1,
                                height: 1,
                              ),
                            ),
                        itemCount: state.algoData?.length ?? 0);
                  } else if (state is AlgorithmLoading) {
                    return const SizedBox(
                      height: 400,
                      child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryColor),
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  RichText _logo() {
    return RichText(
        text: const TextSpan(children: [
      TextSpan(
          text: "XYZ",
          style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryColor,
              fontStyle: FontStyle.italic)),
      WidgetSpan(
        child: SizedBox(width: 8),
      ),
      TextSpan(
          text: "Trade",
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.w400, color: Colors.orange)),
    ]));
  }

  showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text(
              "Are you sure that you want to logout XYZ Trade application?"),
          actions: [
            TextButton(
              child: const Text(
                "Cancel",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                CacheRepository.clearAllData();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                        builder: (BuildContext context) => BlocProvider(
                              create: (context) => LoginBloc(),
                              child: const TradeLogin(),
                            )),
                    (route) => false);
              },
            ),
          ],
        );
      },
    );
  }
}
