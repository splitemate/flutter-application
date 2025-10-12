import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/models/ledger.dart';
import 'package:splitemate/viewmodels/ledgers_view_model.dart';

class LedgersCubit extends Cubit<List<Ledger>> {
  final LedgersViewModel viewModel ;
  LedgersCubit(this.viewModel) : super([]);

  Future<void> ledgers(LedgerType ledgerType) async {
    final ledgers = await viewModel.getLedgers(ledgerType);
    emit(ledgers);
  }

  // Refresh ledgers to update unread counts
  Future<void> refreshLedgers() async {
    // Refresh both individual and group ledgers
    final individualLedgers = await viewModel.getLedgers(LedgerType.individual);
    final groupLedgers = await viewModel.getLedgers(LedgerType.group);
    
    // Combine and emit all ledgers
    final allLedgers = [...individualLedgers, ...groupLedgers];
    emit(allLedgers);
  }

  // Update unread count for a specific ledger
  Future<void> updateLedgerUnreadCount(String ledgerId, LedgerType ledgerType) async {
    try {
      final updatedLedgers = await viewModel.getLedgers(ledgerType);
      final currentState = List<Ledger>.from(state);
      
      // Update the specific ledger in current state
      for (int i = 0; i < currentState.length; i++) {
        if (currentState[i].id == ledgerId && currentState[i].type == ledgerType) {
          final updatedLedger = updatedLedgers.firstWhere(
            (l) => l.id == ledgerId,
            orElse: () => currentState[i],
          );
          currentState[i] = updatedLedger;
          break;
        }
      }
      
      emit(currentState);
    } catch (e) {
      print('Error updating ledger unread count: $e');
    }
  }
}
