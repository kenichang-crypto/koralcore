library;

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Database helper for managing local SQLite database.
/// Handles Scene and Favorite data persistence.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, 'koralcore.db');

    return await openDatabase(
      path,
      version: 8,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add devices table for version 2
      await db.execute('''
        CREATE TABLE IF NOT EXISTS devices (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          rssi INTEGER NOT NULL DEFAULT -65,
          state TEXT NOT NULL DEFAULT 'disconnected',
          provisioned INTEGER NOT NULL DEFAULT 0,
          is_master INTEGER NOT NULL DEFAULT 0,
          is_favorite INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_devices_state ON devices(state)');
    }
    if (oldVersion < 3) {
      // Add drop_type table for version 3
      await db.execute('''
        CREATE TABLE IF NOT EXISTS drop_type (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          is_preset INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_drop_type_name ON drop_type(name)');
    }
    if (oldVersion < 4) {
      // Add new device fields for version 4: macAddress, sinkId, type, group, delayTime
      await db.execute('''
        ALTER TABLE devices ADD COLUMN mac_address TEXT
      ''');
      await db.execute('''
        ALTER TABLE devices ADD COLUMN sink_id TEXT
      ''');
      await db.execute('''
        ALTER TABLE devices ADD COLUMN type TEXT
      ''');
      await db.execute('''
        ALTER TABLE devices ADD COLUMN device_group TEXT
      ''');
      await db.execute('''
        ALTER TABLE devices ADD COLUMN delay_time INTEGER
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_devices_mac_address ON devices(mac_address)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_devices_sink_id ON devices(sink_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_devices_type ON devices(type)');
    }
    if (oldVersion < 5) {
      // Add sink table and sink_device_relation table for version 5
      await db.execute('''
        CREATE TABLE IF NOT EXISTS sink (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS sink_device_relation (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sink_id TEXT NOT NULL,
          device_id TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          UNIQUE(sink_id, device_id),
          FOREIGN KEY (sink_id) REFERENCES sink(id) ON DELETE CASCADE,
          FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_sink_device_relation_sink_id ON sink_device_relation(sink_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_sink_device_relation_device_id ON sink_device_relation(device_id)');
    }
    if (oldVersion < 6) {
      // Add drop_head table for version 6
      await db.execute('''
        CREATE TABLE IF NOT EXISTS drop_head (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          device_id TEXT NOT NULL,
          head_id TEXT NOT NULL,
          pump_id INTEGER NOT NULL,
          additive_name TEXT,
          daily_target_ml REAL NOT NULL DEFAULT 30.0,
          today_dispensed_ml REAL NOT NULL DEFAULT 0.0,
          flow_rate_ml_per_min REAL NOT NULL DEFAULT 1.0,
          last_dose_at INTEGER,
          status_key TEXT NOT NULL DEFAULT 'idle',
          status TEXT NOT NULL DEFAULT 'idle',
          drop_type_id INTEGER,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          UNIQUE(device_id, head_id),
          FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE,
          FOREIGN KEY (drop_type_id) REFERENCES drop_type(id) ON DELETE SET NULL
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_drop_head_device_id ON drop_head(device_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_drop_head_head_id ON drop_head(head_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_drop_head_drop_type_id ON drop_head(drop_type_id)');
    }
    if (oldVersion < 8) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS led_schedules (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          device_id TEXT NOT NULL,
          schedule_id TEXT NOT NULL,
          title TEXT NOT NULL,
          type TEXT NOT NULL,
          recurrence TEXT NOT NULL,
          start_minutes INTEGER NOT NULL,
          end_minutes INTEGER NOT NULL,
          is_enabled INTEGER NOT NULL DEFAULT 1,
          channels_json TEXT,
          scene_name TEXT,
          created_at INTEGER NOT NULL,
          UNIQUE(device_id, schedule_id)
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_led_schedules_device_id ON led_schedules(device_id)');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Devices table
    await db.execute('''
      CREATE TABLE devices (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        rssi INTEGER NOT NULL DEFAULT -65,
        state TEXT NOT NULL DEFAULT 'disconnected',
        provisioned INTEGER NOT NULL DEFAULT 0,
        is_master INTEGER NOT NULL DEFAULT 0,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        mac_address TEXT,
        sink_id TEXT,
        type TEXT,
        device_group TEXT,
        delay_time INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Scene table
    await db.execute('''
      CREATE TABLE scenes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT NOT NULL,
        scene_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        icon_id INTEGER NOT NULL,
        cold_white INTEGER NOT NULL DEFAULT 0,
        royal_blue INTEGER NOT NULL DEFAULT 0,
        blue INTEGER NOT NULL DEFAULT 0,
        red INTEGER NOT NULL DEFAULT 0,
        green INTEGER NOT NULL DEFAULT 0,
        purple INTEGER NOT NULL DEFAULT 0,
        uv INTEGER NOT NULL DEFAULT 0,
        warm_white INTEGER NOT NULL DEFAULT 0,
        moon_light INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        UNIQUE(device_id, scene_id)
      )
    ''');

    // Favorite scenes table (device-scene relationship)
    await db.execute('''
      CREATE TABLE favorite_scenes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT NOT NULL,
        scene_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        UNIQUE(device_id, scene_id)
      )
    ''');

    // Favorite devices table
    await db.execute('''
      CREATE TABLE favorite_devices (
        device_id TEXT PRIMARY KEY,
        created_at INTEGER NOT NULL
      )
    ''');

    // Drop type table
    await db.execute('''
      CREATE TABLE drop_type (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        is_preset INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Sink table
    await db.execute('''
      CREATE TABLE sink (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Sink-Device relation table
    await db.execute('''
      CREATE TABLE sink_device_relation (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sink_id TEXT NOT NULL,
        device_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        UNIQUE(sink_id, device_id),
        FOREIGN KEY (sink_id) REFERENCES sink(id) ON DELETE CASCADE,
        FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE
      )
    ''');

    // Drop head table
    await db.execute('''
      CREATE TABLE drop_head (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT NOT NULL,
        head_id TEXT NOT NULL,
        pump_id INTEGER NOT NULL,
        additive_name TEXT,
        daily_target_ml REAL NOT NULL DEFAULT 30.0,
        today_dispensed_ml REAL NOT NULL DEFAULT 0.0,
        flow_rate_ml_per_min REAL NOT NULL DEFAULT 1.0,
        last_dose_at INTEGER,
        status_key TEXT NOT NULL DEFAULT 'idle',
        status TEXT NOT NULL DEFAULT 'idle',
        drop_type_id INTEGER,
        max_drop INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        UNIQUE(device_id, head_id),
        FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE,
        FOREIGN KEY (drop_type_id) REFERENCES drop_type(id) ON DELETE SET NULL
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_devices_state ON devices(state)');
    await db.execute('CREATE INDEX idx_devices_mac_address ON devices(mac_address)');
    await db.execute('CREATE INDEX idx_devices_sink_id ON devices(sink_id)');
    await db.execute('CREATE INDEX idx_devices_type ON devices(type)');
    await db.execute('CREATE INDEX idx_scenes_device_id ON scenes(device_id)');
    await db.execute('CREATE INDEX idx_favorite_scenes_device_id ON favorite_scenes(device_id)');
    await db.execute('CREATE INDEX idx_drop_type_name ON drop_type(name)');
    await db.execute('CREATE INDEX idx_sink_device_relation_sink_id ON sink_device_relation(sink_id)');
    await db.execute('CREATE INDEX idx_sink_device_relation_device_id ON sink_device_relation(device_id)');
    await db.execute('CREATE INDEX idx_drop_head_device_id ON drop_head(device_id)');
    await db.execute('CREATE INDEX idx_drop_head_head_id ON drop_head(head_id)');
    await db.execute('CREATE INDEX idx_drop_head_drop_type_id ON drop_head(drop_type_id)');

    await db.execute('''
      CREATE TABLE led_schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT NOT NULL,
        schedule_id TEXT NOT NULL,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        recurrence TEXT NOT NULL,
        start_minutes INTEGER NOT NULL,
        end_minutes INTEGER NOT NULL,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        channels_json TEXT,
        scene_name TEXT,
        created_at INTEGER NOT NULL,
        UNIQUE(device_id, schedule_id)
      )
    ''');
    await db.execute('CREATE INDEX idx_led_schedules_device_id ON led_schedules(device_id)');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}

