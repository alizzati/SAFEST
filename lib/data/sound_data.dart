// data/sound_data.dart

class SoundItem {
  final String id;
  final String text;
  final String audioPath;

  SoundItem({required this.id, required this.text, required this.audioPath});
}

class SoundData {
  static final List<SoundItem> emergencySounds = [
    SoundItem(
      id: '1',
      text: "Stay here, I feel unsafe",
      audioPath: 'sounds/stay_here.mp3',
    ),
    SoundItem(
      id: '2',
      text: "I'm being followed, help me.",
      audioPath: 'sounds/im_followed.mp3',
    ),
    SoundItem(
      id: '3',
      text: "Help! I'm in danger!",
      audioPath: 'sounds/help_im_danger.mp3',
    ),
    SoundItem(
      id: '4',
      text: "This is an emergency",
      audioPath: 'sounds/thisis_emergency.mp3',
    ),
    SoundItem(
      id: '5',
      text: "Call for help",
      audioPath: 'sounds/call_for_help.mp3',
    ),
    SoundItem(
      id: '6',
      text: "I need assistance",
      audioPath: 'sounds/i_need_asistance.mp3',
    ),
    SoundItem(
      id: '7',
      text: "Emergency situation",
      audioPath: 'sounds/emergency_situation.mp3',
    ),
  ];

  // Sound khusus untuk tombol sirene
  static final SoundItem sireneSound = SoundItem(
    id: 'sirene_button',
    text: "Sirene Emergency",
    audioPath: 'sounds/sirine.mp3',
  );
}
