import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:seatly/core/utils/json_write_read.dart';

import 'package:seatly/domain/classroom.dart';
import 'package:seatly/domain/configuration/layoutType/layout_type.dart';
import 'package:seatly/domain/desk.dart';
import 'package:seatly/domain/position.dart';
import 'package:seatly/repository/classroom/i_classroom_repository.dart';

@Singleton(as: IClassroomRepository)
class ClassroomRepository implements IClassroomRepository {
  final String fileName = 'classroomSeperator.json';
  final JsonWriteRead _jsonWriteRead;

  ClassroomRepository({
    required JsonWriteRead jsonWriteRead,
  }) : _jsonWriteRead = jsonWriteRead;

  @override
  Future<Classroom?> readClassroom(String id) async {
    final file = await _jsonWriteRead.getFile(fileName);
    final data = await _jsonWriteRead.readDataFromFile(file);
    final classrooms = _parseClassrooms(data);

    return classrooms.firstWhereOrNull((classroom) => classroom.id == id);
  }

  @override
  Future<List<Classroom>> readAllClassrooms() async {
    final file = await _jsonWriteRead.getFile(fileName);
    final data = await _jsonWriteRead.readDataFromFile(file);

    return _parseClassrooms(data);
  }

  @override
  Future<void> createClassroom(Classroom classroom) async {
    final file = await _jsonWriteRead.getFile(fileName);
    final data = await _jsonWriteRead.readDataFromFile(file);

    if (!data.containsKey('classrooms')) {
      data['classrooms'] = [];
    }

    data['classrooms'].add(classroom.toJson());
    await _jsonWriteRead.writeDataToFile(file, data);
  }

  @override
  Future<void> updateClassroom(Classroom classroom) async {
    final file = await _jsonWriteRead.getFile(fileName);
    final data = await _jsonWriteRead.readDataFromFile(file);

    if (!data.containsKey('classrooms')) {
      throw Exception('No classrooms found');
    }

    final classrooms = _parseClassrooms(data);
    final index = classrooms.indexWhere((c) => c.id == classroom.id);
    if (index >= 0) {
      classrooms[index] = classroom;
      data['classrooms'] = classrooms.map((e) => e.toJson().cast<String, Object>()).toList();
      await _jsonWriteRead.writeDataToFile(file, data);
    } else {
      throw Exception('Classroom with id ${classroom.id} not found');
    }
  }

  @override
  Future<void> deleteClassroom(String id) async {
    final file = await _jsonWriteRead.getFile(fileName);
    final data = await _jsonWriteRead.readDataFromFile(file);

    if (!data.containsKey('classrooms')) {
      throw Exception('No classrooms found');
    }

    final classrooms = _parseClassrooms(data);
    final index = classrooms.indexWhere((c) => c.id == id);

    if (index >= 0) {
      classrooms.removeAt(index);
      data['classrooms'] = classrooms.map((e) => e.toJson().cast<String, Object>()).toList();
      await _jsonWriteRead.writeDataToFile(file, data);
    } else {
      throw Exception('Classroom with id $id not found');
    }
  }

  @override
  Future<void> createAllClassrooms(List<Classroom> classrooms) async {
    final file = await _jsonWriteRead.getFile(fileName);
    final data = await _jsonWriteRead.readDataFromFile(file);

    if(!data.containsKey('classrooms')){
      data['classrooms'] = [];
    }

    data['classrooms'].addAll(classrooms.map((e) => e.toJson()).toList());
    await _jsonWriteRead.writeDataToFile(file, data);
  }

  @override
  Future<void> initializeClassrooms() async {
    final classrooms = [
      Classroom(
          id: '1',
          name: 'INF101 - A',
          layoutType: LayoutType.labLayout,
          desks: [
            Desk(id: '1', position: Position(row: 1, column: 1), assignedStudentId: 'student1'),
            Desk(id: '2', position: Position(row: 1, column: 2), assignedStudentId: 'student2'),
            Desk(id: '3', position: Position(row: 2, column: 1), assignedStudentId: null),
            Desk(id: '4', position: Position(row: 2, column: 2), assignedStudentId: null)
          ],
          studentIds: ['student1', 'student2']
      ),
      Classroom(
          id: '2',
          name: 'INF101 - B',
          layoutType: LayoutType.rowByRow,
          desks: [
            Desk(id: '1', position: Position(row: 1, column: 1), assignedStudentId: 'student4'),
            Desk(id: '2', position: Position(row: 1, column: 2), assignedStudentId: 'student5'),
            Desk(id: '3', position: Position(row: 1, column: 3), assignedStudentId: 'student6')
          ],
          studentIds: ['student4', 'student5', 'student6', 'student7']
      ),
      Classroom(
          id: '3',
          name: 'INF201 - A',
          layoutType: LayoutType.groupedLayout,
          desks: [
            Desk(id: '1', position: Position(row: 1, column: 1), assignedStudentId: 'student8'),
            Desk(id: '2', position: Position(row: 1, column: 2), assignedStudentId: 'student9'),
            Desk(id: '3', position: Position(row: 2, column: 1), assignedStudentId: 'student10')
          ],
          studentIds: ['student8', 'student9', 'student10']
      ),
      Classroom(
          id: '4',
          name: 'INF301 - A',
          layoutType: LayoutType.uShape,
          desks: [
            Desk(id: '1', position: Position(row: 1, column: 1), assignedStudentId: 'student11'),
            Desk(id: '2', position: Position(row: 1, column: 2), assignedStudentId: 'student12'),
            Desk(id: '3', position: Position(row: 2, column: 1), assignedStudentId: 'student13'),
            Desk(id: '4', position: Position(row: 2, column: 2), assignedStudentId: 'student14'),
            Desk(id: '5', position: Position(row: 3, column: 1), assignedStudentId: null),
            Desk(id: '6', position: Position(row: 3, column: 2), assignedStudentId: null)
          ],
          studentIds: ['student11', 'student12', 'student13', 'student14', 'student15', 'student16', 'student17', 'student18']
      )
    ];

    await createAllClassrooms(classrooms);
  }

  List<Classroom> _parseClassrooms(Map<String, dynamic> data) {
    final classroomsJson = data['classrooms'] as List<dynamic>?;
    if(classroomsJson == null){
      return [];
    }
    return classroomsJson.map((e) => Classroom.fromJson(e as Map<String, dynamic>)).toList();
  }
}