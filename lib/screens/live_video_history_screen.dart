import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class LiveVideoHistoryScreen extends StatefulWidget {
  const LiveVideoHistoryScreen({super.key});

  @override
  State<LiveVideoHistoryScreen> createState() => _LiveVideoHistoryScreenState();
}

class _LiveVideoHistoryScreenState extends State<LiveVideoHistoryScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  final List<Map<String, String>> videos = List.generate(
    5,
    (index) => {
      'title': 'Video #${index + 1}',
      'url': 'http://ummuhafidzah.sch.id/safest/video_test.mp4',
      'filename': 'video_${index + 1}.mp4',
      'date': '2025-12-17',
      'time': '${10 + index}:00',
      'location': 'Medan',
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _liveHistoryAppBar(context),
          Expanded(
            child: ListView.builder(
              itemCount: videos.length,
              padding: const EdgeInsets.all(10),
              itemBuilder: (context, index) {
                final video = videos[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: const Icon(
                      Icons.history,
                      size: 40,
                      color: Color(0xFF5A00D0),
                    ),
                    title: Text(
                      video['filename'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(video['title'] ?? ''),
                        const SizedBox(height: 4),
                        Text('Date: ${video['date']} • ${video['time']}'),
                        Text('Location: ${video['location']}'),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.play_circle_fill,
                      color: Color(0xFF5A00D0),
                      size: 32,
                    ),
                    onTap: () => _showVideoDialog(context, video['url']!),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _liveHistoryAppBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06,
        vertical: screenHeight * 0.045,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: const [
          Text(
            'Live Video History',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5A00D0),
            ),
          ),
        ],
      ),
    );
  }

  void _showVideoDialog(BuildContext context, String url) async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));

    await _videoPlayerController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: AspectRatio(
          aspectRatio: _videoPlayerController!.value.aspectRatio,
          child: Chewie(controller: _chewieController!),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _chewieController?.dispose();
              _videoPlayerController?.dispose();
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }
}
