import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabaseFactory {
  Future<Database> createDatabase() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'splitemate.db');

    var database = await openDatabase(dbPath, version: 1, onCreate: populateDb);
    return database;
  }

  void populateDb(Database db, int version) async {
    await _createActivityTable(db);
    await _createUserTable(db);
    await _createSplitDetailsTable(db);
    await _createLedgerTable(db);
    await _createTransactionTable(db);
  }

  _createActivityTable(Database db) async {
    await db.execute("""CREATE TABLE activity(
                    id TEXT PRIMARY KEY,
                    user_id TEXT,
                    group_id TEXT,
                    transaction_id TEXT,
                    activity_type TEXT,
                    related_users_ids TEXT,
                    created_date TEXT
        )""").catchError((e) => print('error creating activity table: $e'));
  }

  _createUserTable(Database db) async {
    await db.execute("""CREATE TABLE user(
                    id TEXT PRIMARY KEY,
                    name TEXT,
                    email TEXT,
                    image_url TEXT
        )""").catchError((e) => print('error creating user table: $e'));
  }

  _createSplitDetailsTable(Database db) async {
    await db.execute("""CREATE TABLE split_details(
                    transaction_id TEXT NOT NULL,
                    user_id TEXT,
                    amount REAL DEFAULT 0,
                    PRIMARY KEY (transaction_id, user_id)
        )""").catchError((e) => print('error creating Split details table: $e'));
  }

  _createLedgerTable(Database db) async {
    await db.execute(
      """CREATE TABLE ledger(
            id TEXT,
            name TEXT,
            type TEXT,
            members TEXT,
            amount REAL DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, 
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
            PRIMARY KEY (id, type)
            )""",
    ).catchError((e) => print('error creating chats table: $e'));
  }

  _createTransactionTable(Database db) async {
    await db.execute("""
    CREATE TABLE transactions(
      id TEXT NOT NULL,
      ledger_id TEXT NOT NULL,
      ledger_type TEXT NOT NULL,
      group_id TEXT NOT NULL,
      payer_id TEXT NOT NULL,
      total_amount TEXT NOT NULL,
      split_count TEXT NOT NULL,
      description TEXT NOT NULL,
      transaction_type TEXT NOT NULL,
      transaction_date TIMESTAMP NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
      created_by TEXT NOT NULL,
      updated_at TIMESTAMP NOT NULL,
      receipt TEXT NOT NULL,
      PRIMARY KEY (id, ledger_id, ledger_type),
      FOREIGN KEY (ledger_id, ledger_type) REFERENCES ledger(id, type)
    )
  """).catchError((e) => print('Error creating transaction table: $e'));
  }
}
