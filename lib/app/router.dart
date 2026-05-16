import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wh3re/providers/auth_provider.dart';
import 'package:wh3re/providers/deep_link_provider.dart';
import 'package:wh3re/presentation/pages/auth/forgot_password_page.dart';
import 'package:wh3re/presentation/pages/auth/login_page.dart';
import 'package:wh3re/presentation/pages/auth/register_page.dart';
import 'package:wh3re/presentation/pages/dashboard/dashboard_page.dart';
import 'package:wh3re/presentation/pages/event/create_event_page.dart';
import 'package:wh3re/presentation/pages/event/edit_event_page.dart';
import 'package:wh3re/presentation/pages/event/event_detail_page.dart';
import 'package:wh3re/presentation/pages/event/invite_page.dart';
import 'package:wh3re/presentation/pages/event/join_event_page.dart';
import 'package:wh3re/presentation/pages/event/poll_page.dart';
import 'package:wh3re/presentation/pages/polling/poll_results_page.dart';
import 'package:wh3re/presentation/pages/event/suggestions_page.dart';
import 'package:wh3re/repositories/repository_providers.dart';

/// Clé racine pour la navigation (SnackBar globaux, etc.).
final rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final deepLinkService = ref.watch(deepLinkServiceProvider);
  final eventRepository = ref.watch(eventRepositoryProvider);
  final authRefresh = ref.watch(authRouterRefreshProvider);

  ref.watch(authStateProvider);

  deepLinkService.setJoinHandler((token) async {
    final event = await eventRepository.joinEventByToken(token);
    return event.id;
  });

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: true,
    refreshListenable: authRefresh,
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      final location = state.matchedLocation;

      final isAuthRoute = location == '/login' ||
          location == '/register' ||
          location == '/forgot-password';

      final isJoinRoute = location.startsWith('/join');

      if (!isAuthenticated) {
        if (isJoinRoute) {
          final token = state.pathParameters['token'];
          if (token != null && token.isNotEmpty) {
            deepLinkService.savePendingJoinToken(token);
          }
          return '/login';
        }
        if (!isAuthRoute) return '/login';
        return null;
      }

      if (isAuthenticated && isAuthRoute) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/events/create',
        name: 'create-event',
        builder: (context, state) => const CreateEventPage(),
      ),
      GoRoute(
        path: '/events/:eventId',
        name: 'event-detail',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return EventDetailPage(eventId: eventId);
        },
        routes: [
          GoRoute(
            path: 'edit',
            name: 'edit-event',
            builder: (context, state) {
              final eventId = state.pathParameters['eventId']!;
              return EditEventPage(eventId: eventId);
            },
          ),
          GoRoute(
            path: 'invite',
            name: 'invite',
            builder: (context, state) {
              final eventId = state.pathParameters['eventId']!;
              return InvitePage(eventId: eventId);
            },
          ),
          GoRoute(
            path: 'poll',
            name: 'answer-poll',
            builder: (context, state) {
              final eventId = state.pathParameters['eventId']!;
              return PollPage(eventId: eventId);
            },
          ),
          GoRoute(
            path: 'results',
            name: 'poll-results',
            builder: (context, state) {
              final eventId = state.pathParameters['eventId']!;
              return PollResultsPage(eventId: eventId);
            },
          ),
          GoRoute(
            path: 'suggestions',
            name: 'suggestions',
            builder: (context, state) {
              final eventId = state.pathParameters['eventId']!;
              return SuggestionsPage(eventId: eventId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/join/:token',
        name: 'join-event',
        builder: (context, state) {
          final token = state.pathParameters['token']!;
          return JoinEventPage(token: token);
        },
      ),
    ],
  );

  deepLinkService.attachRouter(router);
  deepLinkService.consumePendingLink();

  return router;
});
