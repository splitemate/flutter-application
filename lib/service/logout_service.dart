import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sqflite/sqflite.dart';

import 'package:splitemate/providers/user_provider.dart';
import 'package:splitemate/states_management/home/ledgers_cubit.dart';
import 'package:splitemate/states_management/home/activity_cubit.dart';
import 'package:splitemate/states_management/bloc/transaction/transaction_bloc.dart';
import 'package:splitemate/states_management/bloc/activity/activity_bloc.dart';
import 'package:splitemate/states_management/bloc/bnb/bnb_bloc.dart';
import 'package:splitemate/service/ws/ws_service.dart';
import 'package:splitemate/data/factories/db_factory.dart';
import 'package:splitemate/data/datasource/sqflite_datasource.dart';
import 'package:splitemate/data/datasource/datasource_contract.dart';
import 'package:splitemate/routes.dart';

class LogoutService {
  static final LogoutService _instance = LogoutService._internal();
  factory LogoutService() => _instance;
  LogoutService._internal();
  
  // Global navigation key for logout navigation
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> performLogout(BuildContext context) async {
    try {
      print('Starting comprehensive logout...');
      
      // Clear states first to prevent queries to dropped tables
      _clearAllStates(context);
      
      // Clear data
      await _clearSharedPreferences();
      await _clearDatabase();
      
      // Clear providers and BLoCs
      _clearUserProvider(context);
      _resetAllBlocs(context);
      
      // Disconnect services
      await _disconnectWebSockets();
      await _signOutGoogle();
      
      print('Logout completed successfully');
      
      // Try to navigate using global navigator key
      try {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          onBoardingPageRoute,
          (Route<dynamic> route) => false,
        );
        print('Navigation successful using global key');
      } catch (e) {
        print('Navigation error with global key: $e');
        // Fallback to context navigation
        if (context.mounted) {
          try {
            Navigator.pushNamedAndRemoveUntil(
              context,
              onBoardingPageRoute,
              (Route<dynamic> route) => false,
            );
          } catch (e) {
            print('Fallback navigation error: $e');
          }
        }
      }
    } catch (e) {
      print('Error during logout: $e');
      // Ensure user provider is cleared even if other steps fail
      try {
        _clearUserProvider(context);
      } catch (e) {
        print('Error clearing user provider: $e');
      }
    }
  }

  Future<void> _clearSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('SharedPreferences cleared');
    } catch (e) {
      print('Error clearing SharedPreferences: $e');
    }
  }

  Future<void> _clearDatabase() async {
    try {
      final Database db = await LocalDatabaseFactory().getDatabase();
      
      // List of tables to clear (instead of dropping all)
      final List<String> tablesToClear = [
        'transactions',
        'ledgers', 
        'activities',
        'users',
        'receipts'
      ];
      
      for (String tableName in tablesToClear) {
        try {
          await db.execute('DELETE FROM $tableName');
          print('Cleared table: $tableName');
        } catch (e) {
          // Table might not exist, which is fine
          print('Table $tableName not found or already empty: $e');
        }
      }
      
      print('Database cleared successfully');
    } catch (e) {
      print('Error clearing database: $e');
    }
  }

  void _clearAllStates(BuildContext context) {
    try {
      final ledgersCubit = context.read<LedgersCubit>();
      ledgersCubit.emit([]);
      
      final activitiesCubit = context.read<ActivitiesCubit>();
      activitiesCubit.emit([]);
      
      final transactionBloc = context.read<TransactionBloc>();
      transactionBloc.add(const TransactionUnsubscribed());
      
      final activityBloc = context.read<ActivityBloc>();
      activityBloc.add(const ActivityUnsubscribed());
      
      final bnbBloc = context.read<BnbBloc>();
      bnbBloc.add(BnbReset());
    } catch (e) {
      print('Error clearing states: $e');
    }
  }

  Future<void> _disconnectWebSockets() async {
    try {
      final wsService = WebSocketService.getInstance();
      if (wsService.isConnected) {
        await wsService.disconnect();
        print('WebSocket disconnected');
      }
    } catch (e) {
      print('Error disconnecting WebSocket: $e');
    }
  }

  Future<void> _signOutGoogle() async {
    try {
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.signOut();
    } catch (e) {
      print('Error signing out from Google: $e');
    }
  }

  void _clearUserProvider(BuildContext context) {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.clearUser();
      print('User provider cleared');
    } catch (e) {
      print('Error clearing user provider: $e');
    }
  }

  void _resetAllBlocs(BuildContext context) {
    try {
      final transactionBloc = context.read<TransactionBloc>();
      transactionBloc.emit(TransactionInitial());
      
      final activityBloc = context.read<ActivityBloc>();
      activityBloc.emit(ActivityInitial());
          } catch (e) {
      print('Error resetting BLoCs: $e');
    }
  }
} 