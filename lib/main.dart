import 'package:aquayar/config/router/app_router.dart';
import 'package:aquayar/config/superbase/provider/super_base_provoder_impl.dart';
import 'package:aquayar/core/services/init_dependency.dart';
import 'package:aquayar/core/services/locator.dart';
import 'package:aquayar/features/auth/bloc/auth_bloc.dart';
import 'package:aquayar/features/auth/data/models/aquayar_auth_user.dart';
import 'package:aquayar/features/auth/data/repos/auth_repo.dart';
import 'package:aquayar/features/orders/bloc/order_bloc.dart';
import 'package:aquayar/features/locations/data/models/address.dart';
import 'package:aquayar/features/orders/data/repo/order_repository.dart';
import 'package:aquayar/features/payment/bloc/payment_bloc.dart';
import 'package:aquayar/features/payment/data/providers/payment_provider.dart';
import 'package:aquayar/features/payment/data/repositories/payment_repository.dart';
import 'package:aquayar/features/user/bloc/bloc/user_bloc.dart';
import 'package:aquayar/features/user/data/providers/user_provider_implementation.dart';
import 'package:aquayar/features/user/data/repos/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'config/superbase/repository/super_base_repo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Hive.initFlutter();
  Hive.registerAdapter(AddressAdapter());

  Hive.registerAdapter(AquayarAuthUserAdapter());

  await Hive.openBox<AquayarAuthUser>("aquayarAuthUser");

  await Hive.openBox<Address>("address");
  final superBase = SuperBaseRepo(provider: SuperBaseProviderImpl());
  superBase.initialiseSuperbase();
  HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: await getApplicationDocumentsDirectory());
  setUp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(AuthRepo.fromDio()),
        ),
        BlocProvider(
          create: (context) => OrderBloc(OrderRepository.getProvider()),
        ),
        BlocProvider(
          create: (context) =>
              UserBloc(UserRepository(provider: UserProviderImplementation())),
        ),
        BlocProvider(
          create: (context) =>
              PaymentBloc(PaymentRepository(PaymentProvider())),
        ),
      ],
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: GetMaterialApp(
          initialBinding: InitializeDependencies(),
          theme: ThemeData(textTheme: const TextTheme()),
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          initialRoute: "/",
          onGenerateRoute: appRouter.onGenerateRoute,
        ),
      ),
    );
  }
}
