import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class DonutDatabase extends GeneratedDatabase {
  DonutDatabase([QueryExecutor? executor])
    : super(
        executor ??
            LazyDatabase(() async {
              final dir = await getApplicationSupportDirectory();
              return NativeDatabase.createInBackground(
                File('${dir.path}/jdonuts.sqlite'),
              );
            }),
      );

  @override
  int get schemaVersion => 1;

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => const [];

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (_) async {
      final seed = jsonDecode(
        await rootBundle.loadString('assets/seed.json'),
      ) as Map<String, dynamic>;
      await transaction(() async {
        await customStatement('''
        CREATE TABLE catalog (
          collection TEXT NOT NULL, position INTEGER NOT NULL,
          payload TEXT NOT NULL, PRIMARY KEY (collection, position)
        )
      ''');
        await customStatement('''
        CREATE TABLE accounts (
          phone TEXT PRIMARY KEY NOT NULL, first_name TEXT NOT NULL,
          last_name TEXT NOT NULL, birth TEXT NOT NULL
        )
      ''');
        await batch((batch) {
          for (final entry in seed.entries) {
            final records = entry.value as List;
            for (var i = 0; i < records.length; i++) {
              batch.customStatement('INSERT INTO catalog VALUES (?, ?, ?)', [
                entry.key,
                i,
                jsonEncode(records[i]),
              ]);
            }
          }
        });
      });
    },
  );

  Future<List<Map<String, dynamic>>> records(String collection) async {
    final rows = await customSelect(
      'SELECT payload FROM catalog WHERE collection = ? ORDER BY position',
      variables: [Variable(collection)],
    ).get();
    return rows
        .map(
          (row) =>
              jsonDecode(row.read<String>('payload')) as Map<String, dynamic>,
        )
        .toList(growable: false);
  }
}
