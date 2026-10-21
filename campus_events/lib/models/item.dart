import 'package:flutter/material.dart';

enum EventCategory {
  tech('Tech', Icons.computer),
  music('Music', Icons.music_note),
  sports('Sports', Icons.sports_basketball),
  art('Art', Icons.brush),
  science('Science', Icons.science);

  final String label;
  final IconData icon;
  const EventCategory(this.label, this.icon);

  // R2: Exhaustive switch expression
  Color color(ColorScheme scheme) => switch (this) {
        EventCategory.tech => scheme.primary,
        EventCategory.music => scheme.secondary,
        EventCategory.sports => scheme.tertiary,
        EventCategory.art => scheme.error,
        EventCategory.science => scheme.primaryContainer,
      };
}

class Item {
  final String id;
  final String title;
  final EventCategory category;
  final DateTime starts;
  final int capacity;
  final List<String> _attendees;
  final bool isOnline;
  final String location;
  final String? description;
  final bool favourite;

  const Item({
    required this.id,
    required this.title,
    required this.category,
    required this.starts,
    required this.capacity,
    required List<String> attendees,
    required this.isOnline,
    required this.location,
    this.description,
    this.favourite = false,
  }) : _attendees = attendees;

  // R3: Empty constructor defaults
  Item.empty()
      : id = DateTime.now().millisecondsSinceEpoch.toString(),
        title = '',
        category = EventCategory.tech,
        starts = DateTime.now().add(const Duration(days: 1)),
        capacity = 10,
        _attendees = const [],
        isOnline = false,
        location = '',
        description = null,
        favourite = false;

  // R1, R4: Immutable unmodifiable list view and getter-derived bounds
  List<String> get attendees => List.unmodifiable(_attendees);
  int get count => _attendees.length;
  int get freePlaces => capacity - count;
  bool get isFull => count >= capacity;
  bool get isPast => starts.isBefore(DateTime.now());
  bool contains(String name) => _attendees.contains(name);

  // R5: Record getter
  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  Item copyWith({
    String? id,
    String? title,
    EventCategory? category,
    DateTime? starts,
    int? capacity,
    List<String>? attendees,
    bool? isOnline,
    String? location,
    String? description,
    bool? favourite,
    bool clearDescription = false,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      starts: starts ?? this.starts,
      capacity: capacity ?? this.capacity,
      attendees: attendees ?? _attendees,
      isOnline: isOnline ?? this.isOnline,
      location: location ?? this.location,
      description: clearDescription ? null : (description ?? this.description),
      favourite: favourite ?? this.favourite,
    );
  }
}

// 12 seeds containing all 5 mandatory conditions
List<Item> generateSeedItems() {
  final now = DateTime.now();
  return [
    Item(
        id: '1',
        title: 'A very long event title that reaches exactly sixty characters.',
        category: EventCategory.tech,
        starts: now.add(const Duration(days: 2)),
        capacity: 50,
        attendees: ['Alice', 'Bob'],
        isOnline: false,
        location: 'Main Hall',
        description: 'Join us for a tech talk.'),
    Item(
        id: '2',
        title: 'Full Capacity Event',
        category: EventCategory.sports,
        starts: now.add(const Duration(days: 3)),
        capacity: 2,
        attendees: ['Alice', 'Bob'],
        isOnline: false,
        location: 'Gym',
        description: 'Basketball match.'), // At limit
    Item(
        id: '3',
        title: 'Past Event Concert',
        category: EventCategory.music,
        starts: now.subtract(const Duration(days: 1)),
        capacity: 100,
        attendees: ['Charlie'],
        isOnline: false,
        location: 'Auditorium',
        description: 'It was a great show.'), // Past
    Item(
        id: '4',
        title: 'Online Science Webinar',
        category: EventCategory.science,
        starts: now.add(const Duration(days: 4)),
        capacity: 100,
        attendees: [],
        isOnline: true,
        location: 'https://zoom.us/webinar',
        description: 'Science for everyone.'), // Mode on
    Item(
        id: '5',
        title: 'No Description Art Show',
        category: EventCategory.art,
        starts: now.add(const Duration(days: 5)),
        capacity: 30,
        attendees: ['Dave'],
        isOnline: false,
        location: 'Gallery 1'), // No description
    Item(
        id: '6',
        title: 'Tech Meetup',
        category: EventCategory.tech,
        starts: now.add(const Duration(hours: 3)),
        capacity: 20,
        attendees: [],
        isOnline: false,
        location: 'Room 202',
        description: 'Networking.'),
    Item(
        id: '7',
        title: 'Campus Run',
        category: EventCategory.sports,
        starts: now.add(const Duration(days: 7)),
        capacity: 200,
        attendees: ['Eve'],
        isOnline: false,
        location: 'Stadium',
        description: '5K run.'),
    Item(
        id: '8',
        title: 'Guitar Workshop',
        category: EventCategory.music,
        starts: now.add(const Duration(days: 8)),
        capacity: 15,
        attendees: [],
        isOnline: false,
        location: 'Music Room',
        description: 'Learn basics.'),
    Item(
        id: '9',
        title: 'AI Hackathon',
        category: EventCategory.tech,
        starts: now.add(const Duration(days: 10)),
        capacity: 40,
        attendees: ['Frank'],
        isOnline: false,
        location: 'Lab 1',
        description: 'Build an AI tool.'),
    Item(
        id: '10',
        title: 'Physics Lecture',
        category: EventCategory.science,
        starts: now.add(const Duration(days: 12)),
        capacity: 60,
        attendees: [],
        isOnline: false,
        location: 'Lecture Hall A',
        description: 'Quantum mechanics.'),
    Item(
        id: '11',
        title: 'Painting Class',
        category: EventCategory.art,
        starts: now.add(const Duration(days: 14)),
        capacity: 25,
        attendees: [],
        isOnline: false,
        location: 'Studio 3',
        description: 'Watercolors.'),
    Item(
        id: '12',
        title: 'Esports Tournament',
        category: EventCategory.tech,
        starts: now.add(const Duration(days: 15)),
        capacity: 64,
        attendees: ['Grace', 'Heidi'],
        isOnline: true,
        location: 'https://discord.gg/esports',
        description: 'Valorant 5v5.'),
  ];
}
