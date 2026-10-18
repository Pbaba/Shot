import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'home',
      builder: (BuildContext context, GoRouterState state) {
        return const Scaffold(
          body: Center(
            child: Text('Shot - Keep what matters.'),
          ),
        );
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'review',
          name: 'review',
          builder: (BuildContext context, GoRouterState state) {
            return const Scaffold(
              body: Center(
                child: Text('Review Screen'),
              ),
            );
          },
        ),
        GoRoute(
          path: 'deletions',
          name: 'deletions',
          builder: (BuildContext context, GoRouterState state) {
            return const Scaffold(
              body: Center(
                child: Text('Deletion Review Screen'),
              ),
            );
          },
        ),
        GoRoute(
          path: 'completion',
          name: 'completion',
          builder: (BuildContext context, GoRouterState state) {
            return const Scaffold(
              body: Center(
                child: Text('Completion Screen'),
              ),
            );
          },
        ),
      ],
    ),
  ],
);
