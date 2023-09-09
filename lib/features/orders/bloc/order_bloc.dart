import 'package:aquayar/features/locations/data/providers/location_provider.dart';
import 'package:aquayar/features/orders/data/repo/order_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../data/models/driver.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc(OrderRepository repo) : super(OrderInitial()) {
    on<OrderEventGetOrders>((event, emit) async {
      emit(OrderStateIsLoading());
      final orders = await repo.getAllOrders();
      orders.fold((l) => emit(OrderStateError(error: l)), (r) {
        emit(OrderStateOrderRetrieved(orders: r));
      });
    });

    on<OrderEventGetNearestDriver>((event, emit) async {
      emit(OrderStateGetNearestDriverIsLoading());

      final double waterSize = event.waterSize;
      final String address = event.address;

      final location = await LocationProvider().getPlace(address);

      final driver = await repo.getNearestDriver(
        waterSize: waterSize,
        longitude: location?["geometry"]["location"]["lng"],
        latitude: location?["geometry"]["location"]["lat"],
      );

      driver.fold((l) {
        emit(OrderStateGetNearestDiverError(error: l));
      }, (r) {
        emit(OrderStateGetNearestDriverFound(driver: r));
      });
    });

    on<OrderEventGetPrice>((event, emit) async {
      emit(OrderStateIsLoading());
      final String token = event.token;
      final double waterSize = event.waterSize;
      final String startLocation = event.startLocation;
      final String endLocation = event.endLocation;

      final response = await repo.getPrice(
          startLocation: startLocation,
          endLocation: endLocation,
          waterSize: waterSize,
          token: token);
      response.fold((l) => emit(OrderStateGetPriceError(error: l)), (r) {
        emit(OrderStatePriceRetrieved(
            distance: r["distance"],
            price: r["data"]["price"] ?? 200,
            time: r["time"]));
      });
    });
  }
}